pragma solidity ^0.4.0;
contract RegisterTestWithLog_12_Test17 {

    uint reward = 1 ether; //The amount that a user has to pay in order to register a domain
    Domain[] public Domains; //Domains is a dynamiclly saized array that has Domain struct inside of it and keeps the state of ll the domains of the contract

    /*enum State {Started, Terminated}
    State public state;

    modifier inState(State _state) {
        if (state != _state) throw;
        _;
    }*/

    struct Domain{ //Domain struct represents each domain which poseses DomainName, RegistrantName, Validity
      bytes32 DomainName;
      address DomainOwner;
      uint RegistrationTime;
      bytes32 TLSKey;
      bytes32 DNSHash;
      bool TLSKey_Flag;     //There is no null in solidity and a default value for a variable before being initialized is 0 (boolean var default value = 0 which is false).
      bool DNSHash_Flag;    //TLSKey_Flag is set to true once the TLSKey of a domain is initialized.
                            // Same for DNSHash_Flag.
    }
//************************************************************************************************************************//
//This function checks whether a domain has been registered and/or expired

    function DomainIsRegistered (bytes32 _DomainName) internal  returns(bool) {



        for(uint i = 0; i < Domains.length; i++ ){

            if (Domains[i].DomainName == _DomainName && now <= Domains[i].RegistrationTime + 5 minutes )//if Domain has been registered and not yet expired
                {
                    return true;

                }
            if (Domains[i].DomainName == _DomainName &&  now >= Domains[i].RegistrationTime + 5 minutes && Domains[i].DomainOwner == msg.sender)//if Domain has been registered and expired and the domainowner equals to msg.sender
                {   block.coinbase.transfer(reward);
                    Domains[i].RegistrationTime = now;  // In this case all the elements of the domain including DomainName, TLSKey, and DNSHash will stay the same.
                    return true;}                       // And only the registration time will set to now (renewed).
            if (Domains[i].DomainName == _DomainName &&  now >= Domains[i].RegistrationTime + 5 minutes && Domains[i].DomainOwner != msg.sender)//if Domain has been registered and expired and the domainowner is not equal to msg.sender
                {   //In this case all the elements of the domain will change + TLSKey and DNSHash will be deleted (Their flags get back to false)
                    //The new registrant has to add his own values for TLSKey and DNSHash.
                    block.coinbase.transfer(reward);
                    Domains[i].DomainOwner = msg.sender;
                    Domains[i].RegistrationTime = now;
                    delete Domains[i].TLSKey;
                    Domains[i].TLSKey_Flag = false;
                    delete Domains[i].DNSHash;
                    Domains[i].DNSHash_Flag = false;
                    return true;}
            if(Domains[i].DomainName != _DomainName) //if Domain has not been registered
                {
                    return false;

                }

        }

    }

//************************************************************************************************************************//
//This function gets arguments from user and register the domain by adding a domian struct to Domians array

    function Register (bytes32 _DomainName)  payable public returns(bool success){
        if (msg.value == reward)
        {
            if(DomainIsRegistered(_DomainName) == false){ // if the domain has not been registered
                block.coinbase.transfer(reward); // the reward (1 ether) goes to current block miner
                Domain memory newDomain; //Create a new Domain struct, newDomain, in memory before we add it to an array
                newDomain.DomainName = _DomainName;
                newDomain.DomainOwner = msg.sender;
                newDomain.RegistrationTime = now;
                Domains.push(newDomain); //it changes the states by adding the element to the array
            }
        }
        else{throw;}
        return true;
    }
//************************************************************************************************************************//
// This function allows Domain owner to add TLS key to his own Domain
    function Add_Certificate (bytes32 _DomainName,bytes32 _TLSKey)  public returns(bool success){

        for(uint i = 0; i < Domains.length; i++ ){ // if Domain is registered, DomainOwner is the same, and TLSKey has not been initialized before
            if (Domains[i].DomainName == _DomainName &&  Domains[i].DomainOwner == msg.sender && Domains[i].TLSKey_Flag == false)
            {
                Domains[i].TLSKey = _TLSKey;
                Domains[i].DNSHash_Flag = true;
            }
            else {throw;}
        }
        return true;
    }
//************************************************************************************************************************//
// This function allows Domain owner to add DNS Hash to his own Domain
    function Add_DnsHash (bytes32 _DomainName,bytes32 _DNSHash)  public returns(bool success){

        for(uint i = 0; i < Domains.length; i++ ){ // if Domain is registered, DomainOwner is the same, and DNSHash has not been initialized before
            if (Domains[i].DomainName == _DomainName &&  Domains[i].DomainOwner == msg.sender && Domains[i].DNSHash_Flag == false)
            {
                Domains[i].DNSHash = _DNSHash;
                Domains[i].DNSHash_Flag = true;
            }
            else {throw;}
        }
        return true;
    }
//************************************************************************************************************************//
// This function allows Domain owner to add both DNS Hash  and TLS Key to his own Domain
    function Add_Certificate_DnsHash (bytes32 _DomainName,bytes32 _TLSKey, bytes32 _DNSHash)  public returns(bool success){

        for(uint i = 0; i < Domains.length; i++ ){
            if (Domains[i].DomainName == _DomainName &&  Domains[i].DomainOwner == msg.sender && Domains[i].DNSHash_Flag == false && Domains[i].TLSKey_Flag == false )
            {
                Domains[i].TLSKey = _TLSKey;
                Domains[i].DNSHash = _DNSHash;
                Domains[i].DNSHash_Flag = true;
                Domains[i].DNSHash_Flag = true;
            }
            else {throw;}
        }
        return true;
    }
//************************************************************************************************************************//
    //this function is a getter function which returns the variable states
    function GetDomain () constant returns  (bytes32[],address[], uint[]) {

        uint length = Domains.length;

        bytes32[] memory DomainNames = new bytes32[](length);
        address[] memory DomainOwners = new address[](length);
        uint[] memory RegistrationTimes = new uint[](length);


        for(uint i = 0; i < Domains.length; i++ ){
            Domain memory currentDomain;
            currentDomain = Domains[i];
            DomainNames[i] = currentDomain.DomainName;
            DomainOwners[i] = currentDomain.DomainOwner;
            RegistrationTimes[i] = currentDomain.RegistrationTime;

        }
        return(DomainNames,DomainOwners,RegistrationTimes);
    }
//************************************************************************************************************************//
/*Constant functions has a limited number of variables in stack. So we have to split our Getter constant function into smaller functions.
Otherwise we'd have an error: Stack is too deep.*/

//this function is a getter function which returns the variable states

    function GetDomainDetails () constant returns  (bytes32[], bytes32[], bool[], bool[]) {

        uint length = Domains.length;


        bytes32[] memory DNSHashs = new bytes32[](length);
        bytes32[] memory TLSKeys = new bytes32[](length);
        bool[] memory TLSKey_Flags = new bool[](length);
        bool[] memory DNSHash_Flags = new bool[](length);

        for(uint i = 0; i < Domains.length; i++ ){
            Domain memory currentDomain;
            currentDomain = Domains[i];

            DNSHashs[i] = currentDomain.DNSHash;
            TLSKeys[i] = currentDomain.TLSKey;
            TLSKey_Flags[i] = currentDomain.TLSKey_Flag;
            DNSHash_Flags[i] = currentDomain.DNSHash_Flag;
        }
        return(DNSHashs,TLSKeys,TLSKey_Flags,DNSHash_Flags);
    }

//************************************************************************************************************************//
}
