// FlowBetPalace.cdc
//
// Welcome to FlowBetPalace! 
// The FlowBetPalace contract contains the whole logic of the bet aplication.
//
// APLICATION ARCHITECTURE BET FLOW
// The flow for create each bet event and its custom wagers("child bets") is create a bet resource(a football match) , 
// add "child" bets resources on each bet resource(who win the match , amount of goals a team scores, wich player scores,...)
// finally the users bet on each "child" bet and get a resource as receipt of the bet
import FlowToken from 0x7e60df042a9c0868
import FungibleToken from 0x9a0766d93b6608b7

access(all) contract FlowBetPalace {

    // betChildData
    // every event childs data will be published by this event every time gets updated and queried by the app
    // betChildUuid is the unique identifier of the child, 
    // while data contains 2 strings array,[[bet options],[quote/odds of each bet]], the bet option index matches with the quote index
    pub event betChildData(data:[[String]],betChildUuid:String,name: String)
    
    
    pub struct ChildBetStruct {
        pub let name: String
        pub let options:[String]
        pub let startDate: UFix64
        pub let stopAcceptingBetsDate: UFix64
        pub let endDate: UFix64
        pub let winnerOptionsIndex: [UInt64]
        pub let odds: [String]
        pub let uuid: String

        init(name: String,options:[String],startDate: UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64,winnerOptionsIndex: [UInt64],odds:[String],uuid: String){
            self.name = name
            self.options = options
            self.startDate = startDate
            self.stopAcceptingBetsDate = stopAcceptingBetsDate
            self.endDate = endDate
            self.winnerOptionsIndex = winnerOptionsIndex
            self.odds = odds
            self.uuid = uuid
        }
    }

    pub struct BetDataStruct {
        pub let name: String
        pub let description: String
        pub let imageLink: String
        pub let category: String
        pub let startDate: UFix64
        pub let stopAcceptingBetsDate: UFix64
        pub let endDate: UFix64

        init(name: String,startDate: UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64,description: String,imageLink:String,category: String){
            self.name = name
            self.startDate = startDate
            self.stopAcceptingBetsDate = stopAcceptingBetsDate
            self.endDate = endDate
            self.description = description
            self.imageLink = imageLink
            self.category = category
        }
    }

    pub struct UserBetStruct {
        pub let amount: UFix64
        pub let childBetUuid: String
        pub let betUuid: String
        pub let childUuid: String
        pub let choosenOption: UInt64
        //later access to the childbet resource
        pub let childBetPath: String
        pub let prizeRequested: Bool
        pub let childBetName: String
        pub let choosenOptionName: String
        init(amount: UFix64,uuid: String, betUuid: String,childBetUuid: String, choosenOption: UInt64,childBetPath: PublicPath,prizeRequested:Bool,childBetName: String,choosenOptionName: String){
            self.amount = amount
            self.childBetUuid = uuid
            self.betUuid = betUuid
            self.choosenOption = choosenOption
            self.childBetPath = childBetPath.toString()
            self.childUuid = childBetUuid
            self.prizeRequested = prizeRequested
            self.childBetName = childBetName
            self.choosenOptionName = choosenOptionName
        }


    }
    //BetPublicInterface
    //public interface of Bet resources
    pub resource interface BetPublicInterface {
        //getBetChildsUuid
        pub fun getBetChilds():[String]

        //getBetData
        pub fun getBetData():BetDataStruct
    }

    //BetPublicInterface
    //public interface of Bet resources
    pub resource interface BetAdminInterface {

        //addChildBetCapability
        //get bet childs uuid
        pub fun getBetChilds():[String]

        //createChildBet
        //create a new child bet resource
        pub fun createChildBet(name:String,options: [String],startDate : UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64):@ChildBet
    }

    //ChildBetPublicInterface
    //public interface of ChildBet resources
    pub resource interface ChildBetPublicInterface {
        pub fun newBet(optionIndex: UInt64,vault : @FungibleToken.Vault): @UserBet
        pub fun chechPrize(bet: @UserBet): @FungibleToken.Vault
        pub fun getData():FlowBetPalace.ChildBetStruct
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


    pub resource interface UserSwitchboardPublicInterface {
        pub fun getFinishedBets(): [UserBetStruct]
        pub fun getMyBetsKeys():[String]
        pub fun getBetData(key:String): UserBetStruct
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
        //ttrack the bet childs uuid of a bet
        access(contract) var childBetsUuid: [String]

        //createChildBet
        //create a new child bet resource
        pub fun createChildBet(name:String,options: [String],startDate : UFix64,endDate: UFix64,stopAcceptingBetsDate: UFix64):@ChildBet{
            //create the new resource
            let newResource <- create ChildBet(name:name,options: options,startDate : startDate,endDate: endDate,stopAcceptingBetsDate: stopAcceptingBetsDate,betUuid:self.uuid.toString())
            //add the betChild uuid to the array that tracks them
            self.childBetsUuid.append(newResource.uuid.toString())
            //emit event of createdBetChild
            return <- newResource
        }

        //getBetChilds
        pub fun getBetChilds():[String]{
            return self.childBetsUuid
        }

        //getBetData
        pub fun getBetData():BetDataStruct{
            return FlowBetPalace.BetDataStruct(
                name: self.name,
                startDate: self.startDate,
                endDate: self.endDate,
                stopAcceptingBetsDate: self.stopAcceptingBetsDate,
                description: self.description,
                imageLink: self.imageLink,
                category: self.category
            )
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
            self.childBetsUuid = []

            // publicPath going to be unique , name is average
            // but endDate determined with milliseconds is a value with uniqueness
            self.storagePath = StoragePath(identifier:"bet".concat(self.uuid.toString()))!
            self.publicPath = PublicPath(identifier: "bet".concat(self.uuid.toString()))!     
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

         access(self) fun getOddsData():[String]{
            // define empty arrays
            var odds: [String] = []
            // add childBet data to arrays
            for index,element in self.options{
                //convert UFix to String
                let oddsString = self.optionOdds[UInt64(index)]!.toString()
                //add quote to qyotes array
                odds.append(oddsString)
            }
            
            return odds
        }

        pub fun newBet(optionIndex: UInt64,vault : @FungibleToken.Vault): @UserBet{
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
            //update self amount
            self.totalAmount = self.totalAmount + amount
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
            // generateOdds
            // based on the amount of each options and the total amount, generate odds for it
            self.generateOdds()
            //return new bet
            return <- create UserBet(amount: amount,uuid: uuid, betUuid: self.betUuid,childBetUuid:uuid,choosenOption: optionIndex,childBetPath: self.publicPath,childBetName: self.name,choosenOptionName: self.options[optionIndex])
        }

        // generateOdds
        // based on the amount of each options and the total amount, generate odds for it
        pub fun generateOdds(){
            for index,element in self.options {
                let indexInt64 = UInt64(index)
                //update option odds 1 + the decimal valu
                self.optionOdds[indexInt64] = self.totalAmount / self.optionsValueAmount[indexInt64]! 

            }
        }

        pub fun chechPrize(bet: @UserBet): @FungibleToken.Vault{
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

        pub fun getData():FlowBetPalace.ChildBetStruct{
            let odds = self.getOddsData()
            
            return FlowBetPalace.ChildBetStruct(
                name:self.name,
                options:self.options,
                endDate:self.endDate,
                startDate:self.startDate,
                stopAcceptingBetsDate:self.stopAcceptingBetsDate,
                winnerOptionsIndex:self.winnerOptionsIndex,
                odds:odds,
                uuid: self.uuid.toString()
            )
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
        pub let childBetName: String
        pub let choosenOptionName: String

        init(amount: UFix64,uuid: String, betUuid: String,childBetUuid: String, choosenOption: UInt64,childBetPath: PublicPath,childBetName: String,choosenOptionName: String){
            self.amount = amount
            self.childBetUuid = uuid
            self.betUuid = betUuid
            self.choosenOption = choosenOption
            self.childBetPath = childBetPath
            self.childUuid = childBetUuid
            self.childBetName = childBetName
            self.choosenOptionName = choosenOptionName
        }
        
    }

    

    /// UserSwitchboardInterface
    // this resource stores all the bets of the user ,
    // the resource is stored on user storage
    pub resource UserSwitchboard: UserSwitchboardPublicInterface  {
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

        //make a struct based on userbet data
            let bet <- self.activeBets.remove(key: uuid)!
            let betDataStruct = UserBetStruct(
                amount: bet.amount,
                uuid: bet.uuid.toString(), 
                betUuid: bet.betUuid,
                childBetUuid: bet.childBetUuid, 
                choosenOption: bet.choosenOption,
                childBetPath: bet.childBetPath,
                prizeRequested: false,
                childBetName: bet.childBetName,
                choosenOptionName: bet.choosenOptionName
            )
            self.finishedBets.insert(at:0,betDataStruct)
            return <- bet
        }

        // getMyBetsKeys
        pub fun getMyBetsKeys():[String]{
            return self.activeBets.keys
        }

        //get bet data
        pub fun getBetData(key:String): UserBetStruct{
            
            //take the userbet
            let bet <- self.activeBets.remove(key:key)!

            //make a struct based on userbet data
            let betDataStruct = UserBetStruct(
                amount: bet.amount,
                uuid: bet.uuid.toString(), 
                betUuid: bet.betUuid,
                childBetUuid: bet.childBetUuid, 
                choosenOption: bet.choosenOption,
                childBetPath: bet.childBetPath,
                prizeRequested: false,
                childBetName: bet.childBetName,
                choosenOptionName: bet.choosenOptionName
            )

            //save back the user bet
            self.activeBets[key] <-! bet

            //return the userbet data of that key
            return betDataStruct
        }

        pub fun getFinishedBets(): [UserBetStruct]{
            return self.finishedBets
        }

        access(contract) var finishedBets: [UserBetStruct]
        destroy (){
            destroy self.activeBets
        }

        init(){
        self.finishedBets = []
            self.activeBets <- {}
        }
    }

    // create Userswitchboard resource for new users
    pub fun createUserSwitchBoard(address: String): @UserSwitchboard{
        //emit an event for help frontend determine if user already has a switchboard
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
            //initialize category if its not
            FlowBetPalace.initializeCategory(key:category)
            //create bet resource
            let newBet <- create Bet(name:name,description:description, imageLink:imageLink,category:category,startDate:startDate,endDate:endDate,stopAcceptingBetsDate:stopAcceptingBetsDate)
            //store the bet for be script-accessible
            FlowBetPalace.betsArray.insert(at:0,[newBet.uuid.toString(),name,description,imageLink,category])
            FlowBetPalace.betsCategoryArray[category]!.insert(at:0,[newBet.uuid.toString(),name,description,imageLink,category])
            return <-newBet
        }
        
    }
    
    pub resource Script {
        pub fun getBets(amount: Int):[[String]]{
            if(FlowBetPalace.betsArray.length>amount){
                return FlowBetPalace.betsArray.slice(from:0,upTo:amount)
            }else{
                return FlowBetPalace.betsArray.slice(from:0,upTo:FlowBetPalace.betsArray.length)
            }
        }

        pub fun getCategoryBets(category: String, amount: Int,skip: Int):[[String]]{
            if(FlowBetPalace.betsCategoryArray[category]!.length>skip+amount){
                return FlowBetPalace.betsCategoryArray[category]!.slice(from: skip,upTo:amount)
            }else{
                if(FlowBetPalace.betsCategoryArray[category]!.length<5){
                    return FlowBetPalace.betsCategoryArray[category]!.slice(from: 0,upTo:FlowBetPalace.betsCategoryArray[category]!.length)
                }else{
                    return FlowBetPalace.betsCategoryArray[category]!.slice(from: 0,upTo:5)

                }
            }
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
    pub let userSwitchBoardPublicPath: PublicPath

    // publicPath for script resource
    pub let scriptPublicPath: PublicPath
    // publicPath for script resource
    pub let scriptStoragePath: StoragePath
    
    // Flow token vault
    access(contract) let flowVault: @FungibleToken.Vault

    //Data to be accesses from scripts
    access(contract) var betsArray: [[String]]
    access(contract) var betsCategoryArray: {String:[[String]]}
    access(contract) var initializedCategoryDictionary: {String:Bool}

    //betsCategoryArray track bets on each category, 
    //as it is a dictionary the key have to be initialized
    //this function checks if the key initialized and if not, just initialize it
    access(contract) fun initializeCategory(key: String){
        if(self.initializedCategoryDictionary[key]==nil){
            //initialize category
            self.betsCategoryArray.insert(key:key,[])
            self.initializedCategoryDictionary.insert(key:key,true)
        }
    }
    // Flow token that recaude fees
    access(contract) let feesVault: @FungibleToken.Vault
    pub let feesPercentage: UFix64
    init(){
        self.storagePath = /storage/flowBetPalace
        self.publicPath = /public/flowBetPalace
        self.adminStoragePath = /storage/flowBetPalaceAdmin
        self.userSwitchBoardPublicPath = /public/flowBetPalaceSwitchboard
        self.userSwitchBoardStoragePath = /storage/flowBetPalaceSwitchboard
        self.adminPublicPath = /public/flowBetPalaceAdmin
        self.scriptPublicPath = /public/flowBetPalaceScript
        self.scriptStoragePath = /storage/flowBetPalaceScript
        self.feesPercentage = 1.0 
        self.betsArray = []
        self.betsCategoryArray = {}
        self.initializedCategoryDictionary = {}
        // store admin resource to creator vault when this contract is deployed 
        self.account.save(<-create Admin(), to: /storage/flowBetPalaceAdmin)

        // create public link to the admin resource
        self.account.link<&AnyResource{FlowBetPalace.AdminInterface}>(/public/flowBetPalaceAdmin, target: /storage/flowBetPalaceAdmin)

        // store admin resource to creator vault when this contract is deployed 
        self.account.save(<-create Script(), to: /storage/flowBetPalaceScript)

        // create public link to the admin resource
        self.account.link<&FlowBetPalace.Script>(/public/flowBetPalaceScript, target: /storage/flowBetPalaceScript)

        //get empty vault
        self.flowVault <- FlowToken.createEmptyVault()
        self.feesVault <- FlowToken.createEmptyVault()
        
    }

}
