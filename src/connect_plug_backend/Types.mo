import Principal "mo:base/Principal";
import Time "mo:base/Time";
import TrieSet "mo:base/TrieSet";
module {
    public type UserInfo = {
        principal : Principal;
        var tokens : TrieSet.Set<Nat>;  
    };

    public type TokenMetadata = {
        tokenUri:Text;
    };

    public type MintResult = {
        #ok : Text;
        #err : Text;
    };

    public type TokenInfo = {
        index : Nat;
        var owner : Principal;
        metadata : TokenMetadata;
        operator : Operator;
        timeStamp : Time.Time
    };

    public type TokenInfoExt = {
        index : Nat;
        owner : Principal;
        metadata : TokenMetadata;
        operator : Operator;
        timeStamp : Time.Time
    };

    public type Operator = {
        #mint;
        #transfer;
    };
}
