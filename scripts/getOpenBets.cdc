import FlowBetPalace from 0x48214e37c07e015b

                pub fun main(addr: Address) :[FlowBetPalace.UserBetStruct]{
                    // Get the accounts wich you want to get the bet
                    let acct1 = getAccount(addr)
                    //get reference of user switchboard
                    let switcboardRef = acct1.getCapability(FlowBetPalace.userSwitchBoardPublicPath)
                                          .borrow<&AnyResource{FlowBetPalace.UserSwitchboardPublicInterface}>()
                                          ?? panic("User dont have any bet yet")
                                          
                    //get keys of the active bets
                    let activeKeys = switcboardRef.getMyBetsKeys()
                    //initialize bets array 
                    let bets: [FlowBetPalace.UserBetStruct] = []
                    //get bet for every key and push to the array
                    for element in activeKeys {
                        let bet = switcboardRef.getBetData(key: element)
                        bets.append(bet)
                    }
                    
                    return bets
                }