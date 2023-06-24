// FlowBetPalace.cdc
//
// Welcome to FlowBetPalace! 
// The FlowBetPalace contract contains the whole logic of the bet aplication.
//
// APLICATION ARCHITECTURE BET FLOW
// The flow of each bet is create a bet resource(a football match) , 
// add "child" bets resources on each bet resource(who win the match , amount of goals a team scores, wich player scores,...)
// finally the users bet on each "child" bet and get a resource as receipt of the bet

access(all) contract FlowBetPalace {

    // storagePath
    // storage path where the Profile resource should be located
    pub let storagePath: StoragePath

    // publicPath
    // the public link for the storagePath
    pub let publicPath: PublicPath
  

    init(){
        self.storagePath = /storage/FlowBetPalace
        self.publicPath = /public/FlowBetPalace
    }

}
