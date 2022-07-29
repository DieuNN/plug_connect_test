import Principal "mo:base/Principal";
module {
    public type UserInfo = {
        principal : Principal;
    };

    public type TokenInfo = {
        tokenUri:Text;
    };
}