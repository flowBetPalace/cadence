// FlowBetPalace.cdc
//
// Welcome to FlowBetPalace! 
// The FlowBetPalace contract contains the whole logic of the bet aplication.
//
// APLICATION ARCHITECTURE BET FLOW
// The flow for create each bet event and its custom wagers("child bets") is create a bet resource(a football match) , 
// add "child" bets resources on each bet resource(who win the match , amount of goals a team scores, wich player scores,...)
// finally the users bet on each "child" bet and get a resource as receipt of the bet

access(all) contract FlowBetPalace {

    // createdBet
    // emit an event when an event has been created 
    pub event createdBet(name: String, description: String, imageLink: String,category: String,startDate: String,endDate: String)

    //BetPublicInterface
    //public interface of Bet resources
    pub resource interface BetPublicInterface {
        
    }

    //BetPublicInterface
    //public interface of Bet resources
    pub resource interface BetAdminInterface {
        
    }

    //ChildBetPublicInterface
    //public interface of ChildBet resources
    pub resource interface ChildBetPublicInterface {
        
    }

    //ChildBetPublicInterface
    //admin interface of ChildBet resources
    pub resource interface ChildBetAdminInterface {
        
    }

    // Bet
    // A Bet represents a Bet created for events such as matches or fights.
    // It stores various data related to the event, excluding information about
    // available child bets and their associated money data.
    pub resource Bet : BetPublicInterface, BetAdminInterface{
        // Bet Data
        pub let name: String
        pub let description: String
        pub let imageLink: String
        pub let category: String
        pub let startDate: String
        pub let endDate: String
        pub let storagePath: StoragePath
        pub let publicPath: PublicPath
        //childBets
        //store all the capabilities of child bets for future fast query of them
        //BAD AS ITS LOW SCALABLE IF U HAVE TO ACCES THE DATA LOT OF TIMES
        //access(contract) var childBets :@{UInt64 : FlowBetPalace.ChildBet}
        //GOOD WITH VERY HIGH SCALABILITY IF HAVE TO ACCES THE DATA LOT OF TITMES
        access(contract) var childBets: [Capability<&AnyResource{FlowBetPalace.ChildBetPublicInterface}>]

        //childBetsPath
        //this is only for development purposes
        access(contract) var childBetsPath: [PublicPath]

        //addChildBetCapability
        //store capabilities that have access to each childPath
        pub fun addChildBetCapability(capability: Capability<&AnyResource{FlowBetPalace.ChildBetPublicInterface}>,path:PublicPath){
            self.childBets.append(capability)
            self.childBetsPath.append(path)
            //future reminder how to acces a capability
            //let ref = capability.borrow()
        }

        //createChildBet
        //create a new child bet resource
        pub fun createChildBet(name:String,options: [String]):@ChildBet{
            return <- create ChildBet(name:name,options: options)
        }

        //resource initializer
        init(name: String,description: String, imageLink: String,category: String,startDate: String,endDate: String){
            self.name = name
            self.description = description
            self.imageLink = imageLink
            self.category = category
            self.startDate = startDate
            self.endDate = endDate
            self.childBets = []
            self.childBetsPath = []

            // publicPath going to be unique , name is average
            // but endDate determined with milliseconds is a value with uniqueness
            var genericPath: String = "/bet/"
            self.storagePath = StoragePath(identifier: "/storage".concat(genericPath).concat(name).concat(endDate))!
            self.publicPath = PublicPath(identifier: "/public".concat(genericPath).concat(name).concat(endDate))!
        }

    }

    // ChildBet
    pub resource ChildBet {

        init(name: String, options: [String]){
        }
    }

    // UserBet
    pub resource UserBet {

    }

    // Admin
    pub resource Admin {

    }

    
    // storagePath for FlowBetPalace account resource
    // storage path where the Profile resource should be located
    pub let storagePath: StoragePath

    // publicPath for FlowBetPalace account resource
    // the public link for the storagePath
    pub let publicPath: PublicPath
  

    init(){
        self.storagePath = /storage/FlowBetPalace
        self.publicPath = /public/FlowBetPalace
    }

}
