/*
 * Copyright (c) Microsoft. All rights reserved. Licensed under the MIT license.
 * See LICENSE in the project root for license information.
 */

import Foundation


// MARK: - Admin
// Applicable to work accounts with admin rights

// Creates a new user in the tenant.
struct CreateUser: Snippet {
    let name = "Create user"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        
        let userId = ProcessInfo.processInfo.globallyUniqueString
        let domainName = "ENTER_DOMAIN_NAME"
        let upn = userId + "@" + domainName
        
        let newUser = MSGraphUser()
        let passwordProfile = MSGraphPasswordProfile()
        passwordProfile.password = "!pass!word1"
        
        newUser.accountEnabled = true
        newUser.displayName = userId
        newUser.passwordProfile = passwordProfile
        newUser.mailNickname = userId
        newUser.userPrincipalName = upn
        
        Snippets.graphClient.users().request().add(newUser) {
            (createdUser, error) in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                guard let displayName = createdUser?.displayName else {
                    completion(.Success(displayText: "User created - no user display name"))
                    return
                }
                completion(.Success(displayText: "User created: \(displayName)"))
            }
        }
    }
}


// Gets a collection of groups that the signed-in user is a member of.
struct GetUserGroups: Snippet {
    let name = "Get user groups"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        
        Snippets.graphClient.me().memberOf().request().getWithCompletion { (userGroupCollection, nextRequest, error) in
            
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            
            var displayString = "List of groups: \n"
            
            if let userGroups = userGroupCollection {
                for userGroup: MSGraphDirectoryObject in userGroups.value as! [MSGraphDirectoryObject] {
                    guard let name = userGroup.dictionaryFromItem()["displayName"] else {
                        completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                        return
                    }
                    displayString += "\(name)\n"
                }
            }
            if let _ = nextRequest {
                displayString += "Next request available for more groups"
            }
            
            completion(.Success(displayText: displayString))
        }
    }
}


// Returns all of the groups in your tenant's directory.
struct GetAllGroups: Snippet {
    let name = "Get all groups"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        Snippets.graphClient.groups().request().getWithCompletion { (allGroupsCollection, nextRequest, error) in
            
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            
            var displayString = "List of all groups: \n"
            
            if let allGroups = allGroupsCollection {
                for group: MSGraphDirectoryObject in allGroups.value as! [MSGraphDirectoryObject] {
                    
                    guard let name = group.dictionaryFromItem()["displayName"] else {
                        completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                        return
                    }
                    displayString += "\(name)\n "
                }
            }
            if let _ = nextRequest {
                displayString += "Next request available for more groups"
            }
            
            
            completion(.Success(displayText: displayString))
            
        }
    }
}


// Gets a specified group.
struct GetSingleGroup: Snippet {
    let name = "Get single group"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        
        // Enter a valid group ID,
        // This can be found from getting list of groups or creating a new group
        let groupId: String = "ENTER_GROUP_ID"
        
        Snippets.graphClient.groups(groupId).request().getWithCompletion({ (singleGroup, error) in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                completion(.Success(displayText: "Retrieved group: \(singleGroup!)"))
            }
        })
    }
}


//Gets a specific group's members.
struct GetMembers: Snippet {
    let name = "Get members"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        
        // Enter a valid group ID,
        // This can be found from getting list of groups or creating a new group
        let groupId: String = "ENTER_GROUP_ID"
       
        Snippets.graphClient.groups(groupId).members().request().getWithCompletion({
            (memberCollection, nextRequest, error) in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                var displayString = "List of members:\n"
                
                for member: MSGraphDirectoryObject in memberCollection!.value as! [MSGraphDirectoryObject] {
                    guard let name = member.dictionaryFromItem()["displayName"] else {
                        completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                        return
                    }
                    displayString += name as! String + "\n"
                }
                
                if let _ = nextRequest {
                    displayString += "Next request available for more members"
                }
                
                completion(.Success(displayText: "List of members:\n\(displayString)"))
            }
        })
    }
}



// Gets a specific group's owners.
struct GetOwners: Snippet {
    let name = "Get owners"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        
        // Enter a valid group ID,
        // This can be found from getting list of groups or creating a new group
        let groupId: String = "ENTER_GROUP_ID" //"047dc3cc-88ce-4f55-82f3-f8fe8c79f393"
        
        Snippets.graphClient.groups(groupId).owners().request().getWithCompletion({
            (memberCollection, nextRequest, error) in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                var displayString = "List of owners:\n"
                
                for member: MSGraphDirectoryObject in memberCollection!.value as! [MSGraphDirectoryObject] {
                    guard let name = member.dictionaryFromItem()["displayName"] else {
                        completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Display name not found")))
                        return
                    }
                    displayString += name as! String + "\n"
                }
                
                if let _ = nextRequest {
                    displayString += "Next request available for more members"
                }
                
                
                completion(.Success(displayText: "List of owners:\n\(displayString)"))
            }
        })
    }
}


// Creates a group in user's account.
struct CreateGroup: Snippet {
    let name = "Create group"
    let needAdminAccess: Bool = true
  
    func execute(with completion: @escaping (Result) -> Void) {
        let group = Snippets.createGroupObject()
        
        Snippets.graphClient.groups().request().add(group) {
            (addedGroup, error) in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                guard let _ = addedGroup else {
                    completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Group ID not returned")))
                    return
                }
                print("id", addedGroup!.entityId)
                completion(.Success(displayText: "Group \(String(describing: addedGroup!.displayName)) was added"))
                
            }
        }
    }
}


// Creates and updates a group in user's account.
struct UpdateGroup: Snippet {
    let name = "Update group"
    let needAdminAccess: Bool = true
    func execute(with completion: @escaping (Result) -> Void) {
        
        // Enter a valid group ID,
        // This can be found from getting list of groups or creating a new group
        let groupId: String = "070fcdec-b187-498e-8c1e-663e3e7fb418" //"047dc3cc-88ce-4f55-82f3-f8fe8c79f393"
    
        Snippets.graphClient.groups(groupId).request().getWithCompletion { (group, error) in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                guard let validGroup = group else {
                    completion(.Failure(error: MSGraphError.UnexpectecError(errorString: "Group ID not returned")))
                    return
                }
                
                validGroup.displayName = "Updated group display name"
                Snippets.graphClient.groups(validGroup.entityId).request().update(validGroup, withCompletion: {
                    (group, error) in
                    if let nsError = error {
                        completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                        return
                    }
                    else {
                        completion(.Success(displayText: "Group \(String(describing: group!.displayName)) updated"))
                    }
                })
            }
        }
    }
}


// Creates and deletes a group in user's account.
struct DeleteGroup: Snippet {
    let name = "Delete group"
    let needAdminAccess: Bool = true
    
    func execute(with completion: @escaping (Result) -> Void) {
        
        // Enter a valid group ID,
        // This can be found from getting list of groups or creating a new group
        let groupId: String = "ENTER_GROUP_ID" //"047dc3cc-88ce-4f55-82f3-f8fe8c79f393"
    
        Snippets.graphClient.groups(groupId).request().delete(completion: { error in
            if let nsError = error {
                completion(.Failure(error: MSGraphError.NSErrorType(error: nsError as NSError)))
                return
            }
            else {
                completion(.Success(displayText: "Group has been deleted"))
            }
        })
    }
}


// MARK: - Helper methods

extension Snippets {

    static func createGroupObject() -> MSGraphGroup {
        let group = MSGraphGroup()
        group.displayName = "New sample group"
        group.mailEnabled = true
        group.mailNickname = "samplemailnickname"
        group.securityEnabled = false
        group.groupTypes = ["Unified"]
        
        return group
    }
}
