// FlowBetPalace.cdc
//
// Welcome to FlowBetPalace! 
// The FlowBetPalace contract contains the whole logic of the bet aplication.
//
// APLICATION ARCHITECTURE BET FLOW
// The flow for create each bet event and its custom wagers("child bets") is create a bet resource(a football match) , 
// add "child" bets resources on each bet resource(who win the match , amount of goals a team scores, wich player scores,...)
// finally the users bet on each "child" bet and get a resource as receipt of the bet
import FlowToken from 0x05

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
    pub event createdBetChilds(betUuid: String,betchildUuid: String,name:String,options:[String])

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
        pub fun newBet(optionIndex: UInt64,vault : @FlowToken.Vault): @UserBet
        pub fun chechPrize(bet: @UserBet): @FlowToken.Vault
    }

    //ChildBetPublicInterface
    //admin interface of ChildBet resources
    pub resource interface ChildBetAdminInterface {
        pub fun setWinnerOptions(winnerOptions: [UInt64])
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
            //create the new resource
            let newResource <- create ChildBet(name:name,options: options,startDate : startDate,endDate: endDate,stopAcceptingBetsDate: stopAcceptingBetsDate,betUuid:self.uuid.toString())
            //emit event of createdBetChild
            emit createdBetChilds(betUuid: self.uuid.toString(),betchildUuid: newResource.uuid.toString(),name:name,options:options)
            return <- newResource
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
        // parent bet uuid
        pub let betUuid: String

        pub let name: String
        // options
        // possible options where the user can bet
        pub let options: [String]

        // winnerOptionsIndex
        // options that have winned
        pub var winnerOptionsIndex: [UInt64]

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
            // define empty arrays
            var options: [String] = []
            var odds: [String] = []
            // add childBet data to arrays
            for index,element in self.options{
                //add option to options array
                options.append(self.options[UInt64(index)])
                //convert UFix to String
                let oddsString = self.optionOdds[UInt64(index)]!.toString()
                //add quote to qyotes array
                odds.append(oddsString)
            }
            //make an array that stores both arrays
            var data:[[String]] = []
            data.append(options)
            data.append(odds)
            // emit event
            emit betChildData(data:data,betChildUuid:self.uuid.toString(),name: self.name)
        }

        pub fun newBet(optionIndex: UInt64,vault : @FlowToken.Vault): @UserBet{
            //return if winners announced
            if(self.winnerOptionsIndex.length>0 || getCurrentBlock().timestamp>self.stopAcceptingBetsDate){
                panic("bet finished")
            }
            // vault balance
            let amountWithFees = vault.balance
            //fees amount
            let feesAmount = amountWithFees * FlowBetPalace.feesPercentage /100.0
            //get vault amount
            let amount = amountWithFees - feesAmount
            //get actual resource uuid
            let uuid = self.uuid.toString()
            //take 1% fees
            let feesVault <- vault.withdraw(amount:feesAmount)
            //deposit fees to fees vault
            FlowBetPalace.feesVault.deposit(from:<-feesVault)
            //add money sended by user to the vault
            FlowBetPalace.flowVault.deposit(from:<-vault)
            //update option value amount
            self.optionsValueAmount[optionIndex] = self.optionsValueAmount[optionIndex]! + UFix64(amount)
            //update option odds 1 + the decimal valu
            self.optionOdds[optionIndex] = self.totalAmount / self.optionsValueAmount[optionIndex]! 
            log("data updated")
            //emit event with new data
            self.emitbetChildData()
            log("event emitted")
            //emit event with new values
            return <- create UserBet(amount: amount,uuid: uuid, betUuid: self.betUuid,childBetUuid:uuid,choosenOption: optionIndex,childBetPath: self.publicPath)
        }

        pub fun chechPrize(bet: @UserBet): @FlowToken.Vault{
            // check if the bet is winner
            let value: Bool = self.winnerOptionsIndex.contains(bet.choosenOption)

            // if its winner give him the reward
            if(value==true){
                // get the won amount
                let amount: UFix64 = bet.amount
                // destroy the bet resource
                destroy bet
                // return a vault with the money
                return <- FlowBetPalace.flowVault.withdraw(amount:amount)
            }else{
                // destroy the bet resource
                destroy bet
                // return an empty vault since the user didnt win anything
                return <- FlowBetPalace.flowVault.withdraw(amount:0.0)
            }
        }

        //set winner options
        pub fun setWinnerOptions(winnerOptions: [UInt64]){
            self.winnerOptionsIndex = winnerOptions
        }


        init(name: String, options: [String],startDate : UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64,betUuid: String){
            self.name = name
            self.options = options
            self.winnerOptionsIndex = []
            self.optionOdds = {}
            self.optionsValueAmount= {}
            self.totalAmount = 0.0
            self.startDate = startDate
            self.endDate = endDate
            self.betUuid = betUuid
            self.stopAcceptingBetsDate = stopAcceptingBetsDate
            self.storagePath = StoragePath(identifier:"betchild".concat(self.uuid.toString()))!
            self.publicPath = PublicPath(identifier: "betchild".concat(self.uuid.toString()))!  
            
            let optionsAmount = options.length

            if(optionsAmount<2){
                panic("you have to add at least 2options")
            }
            //initialize dictionary fields 
            for index,element in options{
                //initialize and add default odds value
                self.optionOdds[UInt64(index)] = 1.5
                //add default value of 1 flow, for the algorithm
                self.optionsValueAmount[UInt64(index)] = 1.0
            }
        }
    }

    // UserBet
    pub resource UserBet {
        pub let amount: UFix64
        pub let childBetUuid: String
        pub let betUuid: String
        pub let childUuid: String
        pub let choosenOption: UInt64
        //later access to the childbet resource
        pub let childBetPath: PublicPath

        init(amount: UFix64,uuid: String, betUuid: String,childBetUuid: String, choosenOption: UInt64,childBetPath: PublicPath){
            self.amount = amount
            self.childBetUuid = uuid
            self.betUuid = betUuid
            self.choosenOption = choosenOption
            self.childBetPath = childBetPath
            self.childUuid = childBetUuid
        }
        
    }

    

    /// UserSwitchboardInterface
    // this resource stores all the bets of the user ,
    // the resource is stored on user storage
    pub resource UserSwitchboard  {
        // stores the active bets that user has started {betuuid:userbetresource}
        access(contract) var activeBets: @{String: UserBet}

        // addBet
        // function that adds a new bet to the user activebets
        pub fun addBet(newBet: @UserBet){
            self.activeBets[newBet.uuid.toString()] <-! newBet
        }
            
        // withdrawBet
        // function that withdraw a bet from the UserSwitchBoard for get the rewards at the child bet resources
        pub fun withdrawBet(uuid: String): @UserBet{
            return <- self.activeBets.remove(key: uuid)!
        }

        // getMyBetsKeys
        pub fun getMyBetsKeys():[String]{
            return self.activeBets.keys
        }

        destroy (){
            destroy self.activeBets
        }

        init(){
            self.activeBets <- {}
        }
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

    // userSwitchBoardStoragePath
    // private path for the user bets switchboard, should be only accessible by the user
    pub let userSwitchBoardStoragePath: StoragePath

    // userSwitchBoardPrivatePath
    // private path for the user bets switchboard, should be only accessible by the user
    pub let userSwitchBoardPrivatePath: PrivatePath
    
    // Flow token vault
    access(contract) let flowVault: @FlowToken.Vault

    // Flow token that recaude fees
    access(contract) let feesVault: @FlowToken.Vault
    pub let feesPercentage: UFix64
    init(){
        self.storagePath = /storage/flowBetPalace
        self.publicPath = /public/flowBetPalace
        self.adminStoragePath = /storage/flowBetPalaceAdmin
        self.userSwitchBoardPrivatePath = /private/flowBetPalaceSwitchboard
        self.userSwitchBoardStoragePath = /storage/flowBetPalaceSwitchboard
        self.adminPublicPath = /public/flowBetPalaceAdmin
        self.feesPercentage = 1.0 
        // store admin resource to creator vault when this contract is deployed 
        self.account.save(<-create Admin(), to: /storage/flowBetPalaceAdmin)

        // create public link to the admin resource
        self.account.link<&AnyResource{FlowBetPalace.AdminInterface}>(/public/flowBetPalaceAdmin, target: /storage/flowBetPalaceAdmin)

        //get empty vault
        self.flowVault <- FlowToken.createEmptyVault()
        self.feesVault <- FlowToken.createEmptyVault()
        
    }

}
