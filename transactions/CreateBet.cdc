import FlowBetPalace from 0x01

transaction {

  prepare(acct: AuthAccount) {
    let name: String = "bet1"
    let startDate: String = "1687771493933"
    let endDate: String = "1687771495935"
    let description: String = "bet desc"
    let imagelink: String = "image"
    let category: String = "football"


    // Retrieve admin Reference of the admin resource
    var acctAdminCapability = acct.getCapability(FlowBetPalace.adminPublicPath)
    var acctAdminRef = acctAdminCapability.borrow<&AnyResource{FlowBetPalace.AdminInterface}>() ?? panic("Could not borrow admin reference")

    // create the new bet
    let newBet <- acctAdminRef.createBet(name: name, description: description, imageLink: imagelink,category: category,startDate: startDate ,endDate: endDate) 

    //get new bet public paths
    let newBetname: String = newBet.name
    let newBetendDate: String = newBet.endDate
    
    // store the new bet details for development purposes
    acctAdminRef.addBet(_publicPath: newBet.publicPath,_storagePath: newBet.storagePath)

    //store the newBet to storage
    // /storage/betname+betenddate
    acct.save(<- newBet, to: StoragePath(identifier: newBetname.concat(newBetendDate))!)
    log("bet saved correctly in account storage")
  }

  execute {
  }
}
