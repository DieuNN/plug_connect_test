import Array "mo:base/Array";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
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
