pragma solidity ^0.4.0;
contract RegisterTestWithMapping_17{
    
    uint reward = 1 ether; //The amount that a user has to pay in order to register a domain
    mapping(bytes32 => Domain) public Domains;
    Domain public CurrentDomain;
    enum Stages {Unregistered,Registered,Expired,TLSKeyEntered,DNSHashEntered,TLSKey_And_DNSHashEntered}
    

//************************************************************************************************************************//    
   struct Domain{ //Domain struct represents each domain which poseses DomainName, RegistrantName, Validity
        bytes32 DomainName;
        address DomainOwner;
        uint RegistrationTime;
        bytes32 TLSKey;
        bytes32 DNSHash;
        Stages state; //Keeps the state of the domain
    
    }
//************************************************************************************************************************//
    //If the user has paid the registration fee and it send s the ether to the current block miner.     
    modifier costs(uint _amount) {
        require(msg.value == _amount);
        _;
        if (msg.value == _amount)
            block.coinbase.transfer(_amount);//the reward is being transfered to the current block miner
    }
//************************************************************************************************************************//
    //If the sender of the message is same as the domain owner.
    modifier OnlyOwner(bytes32 _DomainName) {
        require (Domains[_DomainName].DomainOwner == msg.sender);
        _;
    }

//************************************************************************************************************************//
    //A user can register a domain if and only if its state is either unregistered Or expired.
    modifier InStage(bytes32 _DomainName) {
        require (Domains[_DomainName].state == Stages.Unregistered || Domains[_DomainName].state == Stages.Expired);
        _;
    }
//************************************************************************************************************************//
    //A user can add the TLSKey to his domain if and only if its state is either registered Or DNSHashEntered.
    modifier In_Add_TLSKey_Stage(bytes32 _DomainName) {
        require (Domains[_DomainName].state == Stages.Registered || Domains[_DomainName].state == Stages.DNSHashEntered);
        _;
    }
//************************************************************************************************************************//
    //A user can add the DNSHash to his domain if and only if its state is either registered Or TLSKeyEntered.
    modifier In_Add_DNSHash_Stage(bytes32 _DomainName) {
        require (Domains[_DomainName].state == Stages.Registered || Domains[_DomainName].state == Stages.TLSKeyEntered);
        _;
    }
//************************************************************************************************************************//
    //A user can add the DNSHash and TLSKey  to his domain if and only if its state is registered .
    modifier In_Add_TLSKey_AND_DNSHash_Stage (bytes32 _DomainName){
        require(Domains[_DomainName].state == Stages.Registered);
        _;
    }
//************************************************************************************************************************//    
    //Checks if the domain is expired or not.
    modifier CheckDomainExpiry (bytes32 _DomainName) {
        if (now >= Domains[_DomainName].RegistrationTime + 5 minutes)
        {   
            var DomainVar = Domains[_DomainName];
            DomainVar.state = Stages.Expired;
            Domains[_DomainName] = DomainVar;
        }
        _;
    }
//************************************************************************************************************************//
    //A user can Register a Domain only if the Domain is in "UnRegistered" Or "Expired"
    function Register (bytes32 _DomainName) public CheckDomainExpiry (_DomainName) InStage(_DomainName)
    {   
        CurrentDomain.DomainName = _DomainName;
        CurrentDomain.DomainOwner = msg.sender;
        CurrentDomain.RegistrationTime = now;
        delete CurrentDomain.TLSKey; //Once a Domain has been Expired, the TLSKey and DNSHash will be deleted and should be renewed as well.
        delete CurrentDomain.DNSHash;
        CurrentDomain.state = Stages.Registered;
        Domains[_DomainName] = CurrentDomain;    
        
        
    }
//************************************************************************************************************************//    
    function Add_TLSKey (bytes32 _DomainName,bytes32 _TLSKey)  public CheckDomainExpiry (_DomainName) In_Add_TLSKey_Stage(_DomainName) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.TLSKey = _TLSKey;
        if (DomainVar.state == Stages.DNSHashEntered)               //if the domain contains the TLS Key, it transitions to TLSKey_And_DNSHashEntered.
            {DomainVar.state = Stages.TLSKey_And_DNSHashEntered;}
        else 
            {DomainVar.state = Stages.TLSKeyEntered;}               // Otherwise it transitions to TLSKeyEntered.
        Domains[_DomainName] = DomainVar;
    }

//************************************************************************************************************************//    
    function Add_DNSHash (bytes32 _DomainName,bytes32 _DNSHash)  public CheckDomainExpiry (_DomainName) In_Add_DNSHash_Stage(_DomainName) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.DNSHash = _DNSHash;
        if (DomainVar.state == Stages.TLSKeyEntered)                //if the domain contains the DNS Hash, it transitions to TLSKey_And_DNSHashEntered.
            {DomainVar.state = Stages.TLSKey_And_DNSHashEntered;}
        else                                                        // Otherwise it transitions to DNSHashEntered.
            {DomainVar.state = Stages.DNSHashEntered;}
        Domains[_DomainName] = DomainVar;
    }
//************************************************************************************************************************//    
    function Add_TLSKey_AND_DNSHash (bytes32 _DomainName,bytes32 _TLSKey, bytes32 _DNSHash)  public CheckDomainExpiry (_DomainName) In_Add_TLSKey_AND_DNSHash_Stage(_DomainName) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.DNSHash = _DNSHash;
        DomainVar.TLSKey = _TLSKey;
        DomainVar.state = Stages.TLSKey_And_DNSHashEntered;
        Domains[_DomainName] = DomainVar;
    }
//************************************************************************************************************************//    














}