import FlowBetPalace from 0x01


pub fun main(uuid:String) :[FlowBetPalace.ChildBetStruct]{
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

    let betChildsUuid = betRef.getBetChilds()
    let betChildsData:[FlowBetPalace.ChildBetStruct] = []
    for element in betChildsUuid {
        let path = PublicPath(identifier: "betchild".concat(element))!
        let betChildRef = acct1.getCapability(path)
                          .borrow<&AnyResource{FlowBetPalace.ChildBetPublicInterface }>()
                          ?? panic("Could not borrow acct1 vault reference")
        let data = betChildRef.getData()
        betChildsData.append(data)
    }
    return betChildsData
}
