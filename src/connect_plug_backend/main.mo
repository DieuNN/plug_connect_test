import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import TrieSet "mo:base/TrieSet";

import Types "Types";

actor {
    private stable var _totalSupply : Nat = 0;
    private stable var _numberOfUser : Nat = 0;
    private var _users : HashMap.HashMap<Principal, Types.UserInfo> = HashMap.HashMap<Principal, Types.UserInfo>(0    , Principal.equal, Principal.hash);
    private var _tokens : HashMap.HashMap<Nat, Types.TokenInfo> = HashMap.HashMap<Nat, Types.TokenInfo>(0, Nat.equal, Hash.hash);
    private stable var _userEntries : [(Principal, Types.UserInfo)] = [];
    private stable var _tokenEntries : [(Nat, Types.TokenInfo)] = [];
    
    public func mintNft(to : Text, metadata: Types.TokenMetadata) : async Types.MintResult {
        let principal = Principal.fromText(to);
        _singleMint(principal, metadata);
        return#ok("NFT minted by " # Principal.toText(principal));
    };

    private func _addTokenTo(to : Principal, tokenId : Nat) {
        switch(_users.get(to)) {
            case null {
                let user = _newUser(to);
                user.tokens := TrieSet.put(user.tokens, tokenId, Hash.hash(tokenId), Nat.equal);
                _users.put(to, user);
            };
            case (?user) {
                user.tokens := TrieSet.put(user.tokens, tokenId, Hash.hash(tokenId), Nat.equal);
                _users.put(to, user);
            };
        };
    };

    private func _singleMint(to : Principal, tokenMetadata : Types.TokenMetadata)  {
        _totalSupply += 1;
        let token : Types.TokenInfo = {
            index = _totalSupply;
            var owner = to;
            metadata = tokenMetadata;
            operator = #mint;
            timeStamp = Time.now()
        };

        _tokens.put(_totalSupply, token);
        _addTokenTo(to, _totalSupply);
    };
   
       // check if user exist
    private func _isUserExist(principal : Principal) :  Bool {
        let existingUser = _users.get(principal);
        switch(existingUser) {
            case null {
                return false;
            };
            case (?any) {
                return true;
            };
        }
    };

    private func _newUser(principal: Principal) : Types.UserInfo {
        {
            principal = principal;
            var tokens = TrieSet.empty();
        }
    };

    public func createUser(principal : Text) : async Result.Result<Text, Text> {
        // if user is not exist, create new
        if(not _isUserExist(Principal.fromText(principal))) {
            _numberOfUser +=1;
            _users.put(Principal.fromText(principal), _newUser(Principal.fromText(principal)));
            return#ok("User created");
        };
        return#err("User existed");
    };

    private func _toTokenInfoExt(info : Types.TokenInfo) : Types.TokenInfoExt {
        return {
            index = info.index;
            metadata = info.metadata;
            operator = info.operator;
            owner = info.owner;
            timeStamp = info.timeStamp;
        };
    };

    public func getAllNFTs() : async [Types.TokenInfoExt] {
        var result : [Types.TokenInfoExt] = [];
        
        for(element in _tokens.keys()) {
            let token = _tokens.get(element);
            result := Array.append<Types.TokenInfoExt>(result, [_toTokenInfoExt(Option.unwrap(token))]);
            
        };

        return result;
    };

    // need to parse p cuz i dont know how to change caller, it always anonymous :<
    public func getNFTOfUser(p : Text) : async [Types.TokenInfoExt] {
        var result : [Types.TokenInfoExt] = [];
        for(element in _tokens.keys()) {
            let token = _tokens.get(element);
            if(Principal.equal(Option.unwrap(token).owner, Principal.fromText(p))) {
                result := Array.append<Types.TokenInfoExt>(result, [_toTokenInfoExt(Option.unwrap(token))]);
            }
            
        };

        return result;
    };

    private func _getTokenIdFromTokenMetadata(tokenMetadata : Types.TokenMetadata) :  ?Nat {
        for(element in _tokens.vals()) {
            if(Text.equal(element.metadata.tokenUri, tokenMetadata.tokenUri)) {
                return ?element.index;
            }
        };
        return null;
    };

    public func transfer(from : Text, to : Text, tokenMetadata : Types.TokenMetadata) : async Result.Result<Text, Text> {
        let tokenId = _getTokenIdFromTokenMetadata(tokenMetadata);
        
        switch(tokenId) {
          case null {
            return#err("Token doesn't exist!");
          }; 
          case (?_tokenId) {
            // Debug.print(Nat.toText(_tokenId));
            if(not _isOwner(Principal.fromText(from),_tokenId)) {
                return#err(tokenMetadata.tokenUri # " is not belong to " # from);
            };
            _removeTokenFrom(Principal.fromText(from), _tokenId);
            _addTokenTo(Principal.fromText(to), _tokenId);
          };
        };

        return #ok("OK");
    };

    private func _removeTokenFrom(owner : Principal, tokenId : Nat) {
        assert (_isTokenExist(tokenId) and _isOwner(owner, tokenId));
        switch(_users.get(owner)) {
            case (?user) {
                // user.tokens := TrieSet.delete(user.tokens, tokenId, Hash.hash(tokenId), Nat.equal);
                // for(element in TrieSet.toArray(user.tokens).vals()) {
                //     Debug.print(Nat.toText(element));
                // };
                var userTokensArray : [Nat] = TrieSet.toArray(user.tokens);
                userTokensArray := Array.filter(userTokensArray, func(element : Nat) : Bool {
                    element != tokenId;
                });
                for(element in userTokensArray.vals()) {
                    Debug.print(Nat.toText(element));
                };
                user.tokens := TrieSet.fromArray<Nat>(userTokensArray, Hash.hash, Nat.equal);
                let tempUser : Types.UserInfo = {
                    principal = user.principal;
                    var tokens = TrieSet.fromArray<Nat>(userTokensArray, Hash.hash, Nat.equal);
                };
                _users.put(owner, tempUser);
                Debug.print(Nat.toText(tokenId) # " removed from " # Principal.toText(user.principal));

                assert(true);           
                };
            case null {
                assert(false);
            };
        };
    };



    private func _isTokenExist(tokenId : Nat) : Bool {
        let token = _tokens.get(tokenId);
        switch(token) {
            case null {
                return false;
            };
            case (?any) {
                return true;
            };
        }
    };

    private func _ownerOf(tokenId : Nat) : ?Principal {
        switch(_tokens.get(tokenId)) {
            case (null) {
                return null;
            };
            case (?info) {
                return ?info.owner;
            };
        };
    };

    private func _isOwner(p : Principal, tokenId: Nat) : Bool {
        switch(_tokens.get(tokenId)) {
            case null {
                return false;
            };
            case (?info) {
                return Principal.equal(info.owner, p);
            };
        };
    };

    system func preupgrade() {
        _userEntries := Iter.toArray<(Principal, Types.UserInfo)>(_users.entries());
        _tokenEntries := Iter.toArray<(Nat, Types.TokenInfo)>(_tokens.entries());
    };

    system func postupgrade() {
        _users := HashMap.fromIter<Principal, Types.UserInfo>(_userEntries.vals(), 1, Principal.equal, Principal.hash);
        _tokens := HashMap.fromIter<Nat, Types.TokenInfo>(_tokenEntries.vals(), 1, Nat.equal, Hash.hash);
        
        _userEntries := [];
        _tokenEntries := [];
    };


};
