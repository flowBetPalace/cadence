import FlowBetPalace from 0xd19f554fdb83f838

transaction() {

  prepare(acct: AuthAccount) {
    

    // extract Profile resource of the account
    let profilecopy <- acct.load<@FlowBetPalace.UserSwitchboard>(from: FlowBetPalace.userSwitchBoardStoragePath)
    // if there is not any resrource of the profile create one else save the extracted one
    if(profilecopy == nil){
      //get the user address as required field for the function
      let address = acct.address.toString()

      //create a new UserSwitchBoard resource
      let userSwitchBoardResource <-FlowBetPalace.createUserSwitchBoard(address: address)

      //save the resource in account storage
      acct.save(<- userSwitchBoardResource,to:FlowBetPalace.userSwitchBoardStoragePath)
    
      //create a private link to the storage path
      acct.link<&FlowBetPalace.UserSwitchboard>(FlowBetPalace.userSwitchBoardPrivatePath,target:FlowBetPalace.userSwitchBoardStoragePath)
      log("account switchboard created")
      // destroy the resource as its null
      destroy profilecopy
    }else{
      // save the extracted resource
      // We use the force-unwrap operator `!` to get the value
      // out of the optional. It aborts if the optional is nil
      acct.save(<-profilecopy!,to:FlowBetPalace.userSwitchBoardStoragePath)
      log("account switchboard was already created")
    }
  }

  execute {
  }
}
