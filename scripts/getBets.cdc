import FlowBetPalace from 0x01

// This script gets recent added bets

pub fun main() :[[String]]{
    let amountReturnedBets = 5
    // Get the accounts' public account objects
    let acct1 = getAccount(0x01)

    // Get references to the account's receivers
    // by getting their public capability
    // and borrowing a reference from the capability
    let scriptRef = acct1.getCapability(FlowBetPalace.scriptPublicPath)
                          .borrow<&FlowBetPalace.Script>()
                          ?? panic("Could not borrow acct1 vault reference")

    let bets = scriptRef.getBets(amount: amountReturnedBets)
    log(bets)
    return bets
}
