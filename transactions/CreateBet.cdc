import FlowBetPalace from 0x036703c904a81123

            transaction(name: String, startDate: UFix64, endDate: UFix64, description: String, imagelink: String, category: String, stopAcceptingBetsDate: UFix64) {
                prepare(acct: AuthAccount) {
    
                    // Retrieve admin Reference of the admin resource
                    var acctAdminCapability = acct.getCapability(FlowBetPalace.adminPublicPath)
                    var acctAdminRef = acctAdminCapability.borrow<&AnyResource{FlowBetPalace.AdminInterface}>() ?? panic("Could not borrow admin reference")
                
                    // create the new bet 
                    let newBet <- acctAdminRef.createBet(name: name, description: description, imageLink: imagelink,category: category,startDate: startDate ,endDate: endDate,stopAcceptingBetsDate:stopAcceptingBetsDate) 
                
                    //get the bet storage path
                    let betStoragePath = newBet.storagePath
                    //store the newBet to storage
                    // /storage/"bet"+bet.uuid.toString()
                    acct.save(<- newBet, to: betStoragePath)
                    //create a public link for access the bet 
                    acct.link<&AnyResource{FlowBetPalace.BetPublicInterface}>(betPublicPath,target:betStoragePath)
                    log("bet saved correctly in account storage")
                }
                
                execute {
                }
           
            }