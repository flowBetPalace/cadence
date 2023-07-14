import FlowBetPalace from 0xd19f554fdb83f838


pub fun main(addr: Address):[FlowBetPalace.UserBetStruct] {
    // Get the accounts wich you want to get the bet
    let acct1 = getAccount(addr)
    //get reference of user switchboard
    let switcboardRef = acct1.getCapability(FlowBetPalace.userSwitchBoardPublicPath)
        .borrow<&AnyResource{FlowBetPalace.UserSwitchboardPublicInterface}>()
        ?? panic("User dont have any bet yet")
    //return old bets
    return switcboardRef.getFinishedBets()
}