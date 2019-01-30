pragma solidity ^0.4.0;
contract RegisterTestWithMapping_18{

    uint reward = 1 ether; //The amount that a user has to pay in order to register a domain
    mapping(bytes32 => Domain) public Domains;
    Domain public CurrentDomain;
    enum Stages {Unregistered,Registered,Expired,TLSKeyEntered,DNSHashEntered,TLSKey_And_DNSHashEntered}
    mapping(address => uint) refunds;


//************************************************************************************************************************//
   struct Domain{ //Domain struct represents each domain which poseses DomainName, RegistrantName, Validity
        bytes32 DomainName;
        address DomainOwner;
        uint RegistrationTime;
        bytes32 TLSKey;
        bytes32 DNSHash;
        bool isValue; // IF the Domain struct is initiallized for a key (_DomianName), this value is set to true
        Stages state; //Keeps the state of the domain

    }
//************************************************************************************************************************//
    //If the user has paid the registration fee and it sends the ether to the current block miner.
    modifier Transfer_Costs() {
        if (msg.value < reward) throw;
        if (msg.value >= reward)
        {
            refunds[block.coinbase] += reward;
            uint refund = refunds[block.coinbase];
            refunds[block.coinbase] = 0;
            if (!block.coinbase.send(refund)) {
                refunds[block.coinbase] = refund; // reverting state because send failed
            }
        }
        _;

    }
//************************************************************************************************************************//
    //If the sender of the message is same as the domain owner.
    modifier OnlyOwner(bytes32 _DomainName) {
        require (Domains[_DomainName].DomainOwner == msg.sender);
        _;
    }
//************************************************************************************************************************//
    // If the Domain is in the desired state then the function works. To use the following modifier, a function calls it with 3 arguments (desired arguments).
    modifier AtStage(bytes32 _DomainName, Stages stage_1, Stages stage_2) { //Modifier is declared by 3 parameters.
        require (Domains[_DomainName].state == stage_1  || Domains[_DomainName].state == stage_2);
        _;
    }
//************************************************************************************************************************//
    // If the Domain is not in the spec state then the function works
    modifier Not_AtStage(bytes32 _DomainName, Stages stage_1) {
        if (Domains[_DomainName].state == Stages.Unregistered) throw;
        else
        {
            require (Domains[_DomainName].state != stage_1 );
        }

        _;
    }
//************************************************************************************************************************//
    //Checks if the domain is expired or not.
    modifier CheckDomainExpiry (bytes32 _DomainName) {
        if (Domains[_DomainName].isValue == false)
        {
            Domains[_DomainName].state = Stages.Unregistered;
        }
        else{
            if (now >= Domains[_DomainName].RegistrationTime + 5 years)
            {
                var DomainVar = Domains[_DomainName];
                DomainVar.state = Stages.Expired;
                Domains[_DomainName] = DomainVar;
            }
        }
        _;
    }
//************************************************************************************************************************//
    //A user can Register a Domain only if the Domain is in "Unregistered" Or "Expired"
    function Register (bytes32 _DomainName) public CheckDomainExpiry (_DomainName) AtStage(_DomainName,Stages.Unregistered,Stages.Expired)
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
    //Domain Owner can renew the domain at least 1 year before the domain is expired. Note that Domian validation period is 5 years.
    function Renew (bytes32 _DomainName) public CheckDomainExpiry (_DomainName) OnlyOwner(_DomainName) AtStage(_DomainName,Stages.Registered,Stages.Expired)
    {
        if (now >= Domains[_DomainName].RegistrationTime + 4 years)
        {
            var DomainVar = Domains[_DomainName];
            DomainVar.RegistrationTime = now;
            Domains[_DomainName] = DomainVar;
        }

    }
//************************************************************************************************************************//
    function Add_TLSKey (bytes32 _DomainName,bytes32 _TLSKey)  public CheckDomainExpiry (_DomainName) Not_AtStage(_DomainName,Stages.Expired) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.TLSKey = _TLSKey;
        if (DomainVar.state == Stages.Registered) {DomainVar.state = Stages.TLSKeyEntered;}
        if (DomainVar.state == Stages.DNSHashEntered) {DomainVar.state = Stages.TLSKey_And_DNSHashEntered;}//if the domain contains the DNSHash, it transitions to TLSKey_And_DNSHashEntered.
        //if Domain's state is TLSKeyEntered OR TLSKey_And_DNSHashEntered, it will not  change.
        Domains[_DomainName] = DomainVar;
    }

//************************************************************************************************************************//
    function Add_DNSHash (bytes32 _DomainName,bytes32 _DNSHash)  public CheckDomainExpiry (_DomainName) Not_AtStage(_DomainName,Stages.Expired) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.DNSHash = _DNSHash;
        if (DomainVar.state == Stages.Registered) {DomainVar.state = Stages.DNSHashEntered;}
        if (DomainVar.state == Stages.TLSKeyEntered) {DomainVar.state = Stages.TLSKey_And_DNSHashEntered;}//if the domain contains the TLSKey, it transitions to TLSKey_And_DNSHashEntered.
        //if Domain's state is DNSHashEntered OR TLSKey_And_DNSHashEntered, it will not  change.

        Domains[_DomainName] = DomainVar;
    }
//************************************************************************************************************************//
    function Add_TLSKey_AND_DNSHash (bytes32 _DomainName,bytes32 _TLSKey, bytes32 _DNSHash)  public CheckDomainExpiry (_DomainName) Not_AtStage(_DomainName,Stages.Expired) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.DNSHash = _DNSHash;
        DomainVar.TLSKey = _TLSKey;
        DomainVar.state = Stages.TLSKey_And_DNSHashEntered;
        Domains[_DomainName] = DomainVar;
    }
//************************************************************************************************************************//
    //DomainOwner can transfer the Domain to any address he wants if and only if the Domain is not Unregistered or Expired.
    //"Without_Scrub" term means that the Doamin is transfered along with all its elements including : TLSKey,DNSHash...
    //Note that the Domain State and Registration_Time will not change and remain the same .
    function Transfer_Domain_Without_Scrub (bytes32 _DomainName, address _Reciever) public CheckDomainExpiry (_DomainName) Not_AtStage(_DomainName,Stages.Expired) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.DomainOwner = _Reciever;
        Domains[_DomainName] = DomainVar;
    }
//************************************************************************************************************************//
    //DomainOwner can transfer the Domain to any address he wants if and only if the Domain is not Unregistered or Expired.
    //"With_Scrub" term means that all the elements of the Domain is cleared and the new owner should add the TLSKey or DNSHash again!
    //Note that the Registration_Time will not change and remains the same. However, Domain state will change to Registered.
    function Transfer_Domain_With_Scrub (bytes32 _DomainName, address _Reciever) public CheckDomainExpiry (_DomainName) Not_AtStage(_DomainName,Stages.Expired) OnlyOwner(_DomainName)
    {
        var DomainVar = Domains[_DomainName];
        DomainVar.DomainOwner = _Reciever;
        delete DomainVar.TLSKey;
        delete DomainVar.DNSHash;
        DomainVar.state = Stages.Registered;
        Domains[_DomainName] = DomainVar;
    }
//************************************************************************************************************************//











}
