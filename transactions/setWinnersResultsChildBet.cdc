import FlowBetPalace from 0x01
import FlowToken from 0x05
transaction(uuid: String,optionIndex:[UInt64]) {
    prepare(acct: AuthAccount) {
    
        //set the StoragePath of the bet
        let betPath: StoragePath = StoragePath(identifier:"betchild".concat(uuid))!

        //get the resource
        let bet <- acct.load<@FlowBetPalace.ChildBet>(from: betPath) ?? panic("invalid bet uuid")

        //set the winners
        bet.setWinnerOptions(winnerOptions:optionIndex)

        //save back the resource
        acct.save(<-bet,to:betPath)

    }

    execute {
    }
}
