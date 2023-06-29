import FlowBetPalace from 0x01
import FlowToken from 0x05
transaction(amount: UFix64,uuid: String,userBetUuid: String) {
    prepare(acct: AuthAccount) {
    
        
        // Get a reference to the signer's stored flow vault
        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
			?? panic("Could not borrow reference to the owner's Vault!")

        // extract Profile resource of the account
        let profile <- acct.load<@FlowBetPalace.UserSwitchboard>(from: FlowBetPalace.userSwitchBoardStoragePath) ?? panic("user have not started his account")

        // get admin account that stores resourced
        let accountFlowBetPalace = getAccount(0x01)

        // get reference of the childBet resource
        let childBetRef = accountFlowBetPalace.getCapability<&AnyResource{FlowBetPalace.ChildBetPublicInterface}>(PublicPath(identifier:"betchild".concat(uuid))!)
                            .borrow() ?? panic("invalid childBet uuid")

        //withdraw UserBet from the switchboard
        let userBet <- profile.withdrawBet(uuid:userBetUuid)
        //check if the bet had prize in the childBet resource abd get a vault with the prize
        let vault <- childBetRef.chechPrize(bet: <- userBet)
        //store the vault at the FlowVault (if its a win bet will have flow tokens, else will be empty)
        vaultRef.deposit(from: <- vault)
        // save the extracted resource
        // We use the force-unwrap operator `!` to get the value
        // out of the optional. It aborts if the optional is nil
        acct.save(<-profile,to:FlowBetPalace.userSwitchBoardStoragePath)
    }

    execute {
    }
}
