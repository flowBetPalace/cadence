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

    // betChildData
    // every event childs data will be published by this event every time gets updated and queried by the app
    // betChildUuid is the unique identifier of the child, 
    // while data contains 2 strings array,[[bet options],[quote/odds of each bet]], the bet option index matches with the quote index
    pub event betChildData(data:[[String]],betChildUuid:String,name: String)

    // createbetChilds
    // just emit an event every time a bet child is created for every bet
    pub event createdBetChilds(betUuid: String,betchildUuid: String)

    // setupSwitchBoard
    // emit an event when the user stores the switchboard
    pub event setupSwitchBoard(userAddress: String)

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
        pub fun createChildBet(name:String,options: [String],startDate : UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64):@ChildBet
    }

    //ChildBetPublicInterface
    //public interface of ChildBet resources
    pub resource interface ChildBetPublicInterface {
        
    }

    //ChildBetPublicInterface
    //admin interface of ChildBet resources
    pub resource interface ChildBetAdminInterface {
        
    }

    // UserSwitchboardInterface
    // this resource stores all the bets of the user ,
    // the resource is stored on user storage
    pub resource interface UserSwitchboardInterface {

    }

    pub resource interface AdminInterface {
        // createBet 
        // newBet is created at the resource constructor and event is emitted 
        // application will get bets from this emitted events
        // create bet is restricted for only admins, since an event is emitted at every bet creation, 
        // we only want an event is emitted for the bets created by the organization
        pub fun createBet(name: String,description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64): @Bet

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
        pub let stopAcceptingBetsDate: UFix64
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
        pub fun createChildBet(name:String,options: [String],startDate : UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64):@ChildBet{
            return <- create ChildBet(name:name,options: options,startDate : startDate,endDate: endDate,stopAcceptingBetsDate: stopAcceptingBetsDate)
        }


        //resource initializer
        init(name: String,description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64){
            self.name = name
            self.description = description
            self.imageLink = imageLink
            self.category = category
            self.startDate = startDate
            self.stopAcceptingBetsDate = stopAcceptingBetsDate
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


        init(name: String, options: [String],startDate : UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64){
            self.name = name
            self.options = options
            self.winnerOptionsIndex = []
            self.optionOdds = {}
            self.optionsValueAmount= {}
            self.totalAmount = 0.0
            self.startDate = startDate
            self.endDate = endDate
            self.stopAcceptingBetsDate = stopAcceptingBetsDate
            self.storagePath = StoragePath(identifier:"betchild".concat(self.uuid.toString()))!
            self.publicPath = PublicPath(identifier: "betchild".concat(self.uuid.toString()))!  
        }
    }

    // UserBet
    pub resource UserBet {
        pub let amount: UFix64
        pub let childBetUuid: String
        pub let betUuid: String
        pub let choosenOption: UInt64
        pub let childBetPath: PublicPath

        init(amount: UFix64,uuid: String, betUuid: String,choosenOption: UInt64,childBetPath: PublicPath){
            self.amount = amount
            self.childBetUuid = uuid
            self.betUuid = betUuid
            self.choosenOption = choosenOption
            self.childBetPath = childBetPath
        }
        
    }

    

    /// UserSwitchboardInterface
    // this resource stores all the bets of the user ,
    // the resource is stored on user storage
    pub resource UserSwitchboard: UserSwitchboardInterface  {

    }

    // create Userswitchboard resource for new users
    pub fun createUserSwitchBoard(address: String): @UserSwitchboard{
        //emit an event for help frontend determine if user already has a switchboard
        emit setupSwitchBoard(userAddress:address)
        return <- create UserSwitchboard()
    }

    // Admin
    pub resource Admin: AdminInterface {
        // createBet 
        // newBet is created and event is emitted 
        // application will get bets from this emitted events
        // create bet is restricted for only admins, since an event is emitted at every bet creation, 
        // we only want an event is emitted for the bets created by the organization
        pub fun createBet(name: String,description: String, imageLink: String,category: String,startDate: UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64): @Bet{
            return <- create Bet(name:name,description:description, imageLink:imageLink,category:category,startDate:startDate,endDate:endDate,stopAcceptingBetsDate:stopAcceptingBetsDate)
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

    // adminPublicPath for FlowBetPalace account resource
    // the public link for the storagePath
    pub let adminPublicPath : PublicPath

    // userSwitchBoardPrivatePath
    // private path for the user bets switchboard, should be only accessible by the user
    pub let userSwitchBoardPrivatePath: PrivatePath
    

    init(){
        self.storagePath = /storage/flowBetPalace
        self.publicPath = /public/flowBetPalace
        self.adminStoragePath = /storage/flowBetPalaceAdmin
        self.userSwitchBoardPrivatePath = /private/flowBetPalaceSwitchboard
        self.adminPublicPath = /public/flowBetPalaceAdmin

        // store admin resource to creator vault when this contract is deployed 
        self.account.save(<-create Admin(), to: /storage/flowBetPalaceAdmin)

        // create public link to the admin resource
        self.account.link<&AnyResource{FlowBetPalace.AdminInterface}>(/public/flowBetPalaceAdmin, target: /storage/flowBetPalaceAdmin)
        
    }

}
