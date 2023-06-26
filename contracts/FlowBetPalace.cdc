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
    pub event createdBet(name: String, description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64,uuid: String)

    // betChilds
    // every event childs data will be published by this event every time gets updated and queried by the app
    // betChildUuid is the unique identifier of the child, 
    // while data contains 2 strings array,[[bet options],[quote/odds of each bet]], the bet option index matches with the quote index
    pub event betChildData(data:[[String]],betChildUuid:String,name: String)

    //betChilds
    //just emit an event every time a bet child is created
    pub event createdBetChilds(betUuid: String,betchildUuid: String)

    //BetPublicInterface
    //public interface of Bet resources
    pub resource interface BetPublicInterface {
    }

    //BetPublicInterface
    //public interface of Bet resources
    pub resource interface BetAdminInterface {

        //addChildBetCapability
        //store child bets path
        pub fun addChildBetPath(path:PublicPath)

        //createChildBet
        //create a new child bet resource
        pub fun createChildBet(name:String,options: [String]):@ChildBet
    }

    //ChildBetPublicInterface
    //public interface of ChildBet resources
    pub resource interface ChildBetPublicInterface {
        
    }

    //ChildBetPublicInterface
    //admin interface of ChildBet resources
    pub resource interface ChildBetAdminInterface {
        
    }

    pub resource interface AdminInterface {
        // createBet 
        // newBet is created at the resource constructor and event is emitted 
        // application will get bets from this emitted events
        // create bet is restricted for only admins, since an event is emitted at every bet creation, 
        // we only want an event is emitted for the bets created by the organization
        pub fun createBet(name: String,description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64): @Bet

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
        pub let startDate: UFix64
        pub let endDate: UFix64
        pub let storagePath: StoragePath
        pub let publicPath: PublicPath
        
        //childBetsPath
        //this is only for development purposes and for have a backup of the PublicPaths apart of the events
        access(contract) var childBetsPath: [PublicPath]

        //addChildBetCapability
        //store capabilities that have access to each childPath
        pub fun addChildBetPath(path:PublicPath){
            self.childBetsPath.append(path)
        }

        //createChildBet
        //create a new child bet resource
        pub fun createChildBet(name:String,options: [String]):@ChildBet{
            return <- create ChildBet(name:name,options: options)
        }


        //resource initializer
        init(name: String,description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64){
            self.name = name
            self.description = description
            self.imageLink = imageLink
            self.category = category
            self.startDate = startDate
            self.endDate = endDate
            self.childBetsPath = []

            // publicPath going to be unique , name is average
            // but endDate determined with milliseconds is a value with uniqueness
            self.storagePath = StoragePath(identifier:"bet".concat(self.uuid.toString()))!
            self.publicPath = PublicPath(identifier: "bet".concat(self.uuid.toString()))!     
            emit createdBet(name:name,description:description, imageLink:imageLink,category:category,startDate:startDate,endDate:endDate,uuid:self.uuid.toString())
        }

    }

    // ChildBet
    pub resource ChildBet: ChildBetPublicInterface,  ChildBetAdminInterface{
        pub let name: String
        // options
        // possible options where the user can bet
        pub let options: [String]

        // winnerOptionsIndex
        // options that have winned
        pub let winnerOptionsIndex: [UInt64]

        // optionOdds 
        // decimal odds of of every option
        pub var optionOdds: {UInt64:UFix64}

        // optionsValue
        // when people bet in favor of an option
        // the amount betted in that option is after used to calculate the odds 
        pub var optionsValueAmount: {UInt64:UFix64}

        // totalAmount
        // the total amount that this bet has
        pub var totalAmount: UFix64

        //paths to interact with this bet
        pub let storagePath: StoragePath
        pub let publicPath: PublicPath
        
        //dates
        pub let startDate: UFix64
        pub let endDate: UFix64
        pub let stopAcceptingBetsDate: UFix64
        access(self) fun emitbetChildData(){
        }

        pub fun newBet(){
        }

        pub fun chechPrize(){
        }

        access(contract) fun setWinnerOptions(){
        }


        init(name: String, options: [String]){
            self.name = name
            self.options = options
            self.winnerOptionsIndex = []
            self.optionOdds = {}
            self.optionsValueAmount= {}
            self.totalAmount = 0.0
            self.startDate = 0.0
            self.endDate = 0.0
            self.stopAcceptingBetsDate = 0.0
            self.storagePath = StoragePath(identifier:"betchild".concat(self.uuid.toString()))!
            self.publicPath = PublicPath(identifier: "betchild".concat(self.uuid.toString()))!  
        }
    }

    // UserBet
    pub resource UserBet {

    }

    // Admin
    pub resource Admin: AdminInterface {
        // createBet 
        // newBet is created and event is emitted 
        // application will get bets from this emitted events
        // create bet is restricted for only admins, since an event is emitted at every bet creation, 
        // we only want an event is emitted for the bets created by the organization
        pub fun createBet(name: String,description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64): @Bet{
            return <- create Bet(name:name,description:description, imageLink:imageLink,category:category,startDate:startDate,endDate:endDate)
        }
        
    }

    

    
    // storagePath for FlowBetPalace account resource
    // storage path where the Profile resource should be located
    pub let storagePath: StoragePath

    // publicPath for FlowBetPalace account resource
    // the public link for the storagePath
    pub let publicPath: PublicPath

    // adminStoragePath for FlowBetPalace admin resource
    // adminStoragePath where the admin resource should be located
    pub let adminStoragePath : StoragePath

    // ddminPublicPath for FlowBetPalace account resource
    // the public link for the storagePath
    pub let adminPublicPath : PublicPath
    

    init(){
        self.storagePath = /storage/flowBetPalace
        self.publicPath = /public/flowBetPalace
        self.adminStoragePath = /storage/flowBetPalaceAdmin
        self.adminPublicPath = /public/flowBetPalaceAdmin

        // store admin resource to creator vault when this contract is deployed 
        self.account.save(<-create Admin(), to: /storage/flowBetPalaceAdmin)

        // create public link to the admin resource
        self.account.link<&AnyResource{FlowBetPalace.AdminInterface}>(/public/flowBetPalaceAdmin, target: /storage/flowBetPalaceAdmin)
        
    }

}
