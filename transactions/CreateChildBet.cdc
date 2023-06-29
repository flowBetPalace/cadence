import FlowBetPalace from 0x01

transaction(betUuid: String,name:String,options: [String]) {

  prepare(acct: AuthAccount) {
    
    //set the StoragePath of the bet
    let betPath: StoragePath = StoragePath(identifier:"bet".concat(betUuid))!

    //get the resource
    let bet <- acct.load<@FlowBetPalace.Bet>(from: betPath) ?? panic("invalid bet uuid")

    //create the betChild
    let childBet <- bet.createChildBet(name:name,options:options,startDate:bet.startDate,endDate:bet.endDate,stopAcceptingBetsDate:bet.stopAcceptingBetsDate)

    //save back the resource
    acct.save(<-bet,to:betPath)

    //save the betChildResource
    let childBetPath: StoragePath = childBet.storagePath
    let childBetPublicPath: PublicPath = childBet.publicPath
    acct.save(<-childBet,to:childBetPath)

    //create a link to the storage path
    acct.link<&AnyResource{FlowBetPalace.ChildBetPublicInterface}>(childBetPublicPath,target:childBetPath)

    log("created a childBet, stored in storage and added a public link")
  }

  execute {
  }
}
