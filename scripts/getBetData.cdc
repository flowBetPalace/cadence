import FlowBetPalace from 0x01


pub fun main(uuid:String) :FlowBetPalace.BetDataStruct{
    // Get the accounts' public account objects
    let acct1 = getAccount(0x01)
    //get bet path
    let betPath = PublicPath(identifier: "bet".concat(uuid))!
    // Get references to the account's receivers
    // by getting their public capability
    // and borrowing a reference from the capability
    let betRef = acct1.getCapability(betPath)
                          .borrow<&AnyResource{FlowBetPalace.BetPublicInterface}>()
                          ?? panic("Could not borrow acct1 vault reference")

    let betData = betRef.getBetData()
    return betData
}
