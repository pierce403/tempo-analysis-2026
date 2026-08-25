import {
  createClient,
  custom,
  keccak256,
  stringToHex,
  type Address,
  type Hex,
} from 'viem'
import { privateKeyToAccount } from 'viem/accounts'
import { afterEach, expect, test, vi } from 'vp/test'

import * as Chain from '../precompile/Chain.js'
import { tip20ChannelEscrow } from '../precompile/Protocol.js'
import type * as ChannelStore from './ChannelStore.js'
import { settle } from './Settlement.js'

const payeeAccount = privateKeyToAccount(
  keccak256(stringToHex('tempo-report-c010-local-payee')),
)
const payer = '0x0000000000000000000000000000000000000001' as Address
const channelId = `0x${'11'.repeat(32)}` as Hex
const salt = `0x${'22'.repeat(32)}` as Hex
const expiringNonceHash = `0x${'33'.repeat(32)}` as Hex
const txHash = `0x${'44'.repeat(32)}` as Hex

afterEach(() => vi.restoreAllMocks())

test('public settle captures highest voucher rather than recorded spend', async () => {
  let channel: ChannelStore.State = {
    authorizedSigner: payer,
    backend: 'precompile',
    chainId: 4217,
    channelId,
    closeRequestedAt: 0n,
    createdAt: '2026-08-24T00:00:00.000Z',
    deposit: 100n,
    descriptor: {
      authorizedSigner: payer,
      expiringNonceHash,
      operator: '0x0000000000000000000000000000000000000000',
      payee: payeeAccount.address,
      payer,
      salt,
      token: '0x20c0000000000000000000000000000000000001',
    },
    escrowContract: tip20ChannelEscrow,
    expiringNonceHash,
    finalized: false,
    highestVoucher: {
      channelId,
      cumulativeAmount: 100n,
      signature: '0x1234',
    },
    highestVoucherAmount: 100n,
    operator: '0x0000000000000000000000000000000000000000',
    payee: payeeAccount.address,
    payer,
    salt,
    settledOnChain: 0n,
    spent: 1n,
    token: '0x20c0000000000000000000000000000000000001',
    units: 1,
  }
  const store: ChannelStore.ChannelStore = {
    async getChannel() {
      return channel
    },
    async updateChannel(_id, update) {
      const next = update(channel)
      if (next) channel = next
      return next
    },
  }

  const client = createClient({
    account: payeeAccount,
    chain: { id: 4217 } as never,
    transport: custom({
      async request(args) {
        throw new Error(`unexpected RPC request: ${args.method}`)
      },
    }),
  })

  const settleOnChain = vi.spyOn(Chain, 'settleOnChain').mockResolvedValue(txHash)
  vi.spyOn(Chain, 'waitForSuccessfulReceipt').mockResolvedValue({} as never)
  vi.spyOn(Chain, 'getChannelEvent').mockReturnValue({ args: { newSettled: 100n } } as never)
  vi.spyOn(Chain, 'getChannelState').mockResolvedValue({
    closeRequestedAt: 0,
    deposit: 100n,
    settled: 100n,
  })

  await settle(store, client, channelId)

  const submittedAmount = settleOnChain.mock.calls[0]?.[2]
  const transcript = {
    capturedAboveSpent: (submittedAmount! - 1n).toString(),
    highestVoucher: '100',
    recordedSpent: '1',
    settleSubmittedCumulative: submittedAmount?.toString(),
  }
  console.log(`SETTLEMENT_SKIM_POC ${JSON.stringify(transcript)}`)

  expect(submittedAmount).toBe(100n)
  expect(submittedAmount).not.toBe(1n)
})
