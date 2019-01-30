pragma solidity ^0.4.0;
contract RegisterTestWithLog_8 {



    uint amount = 1 ether;
    Domain[] public Domains; //Domains is a dynamiclly saized array that has Domain struct inside of it and keeps the state of ll the domains of the contract

    struct Domain{ //Domain struct represents each domain which poseses DomainName, RegistrantName, Validity
      bytes32 DomainName;
      bytes32 TLSKey;
      bytes32 DNSHash;
      address DomainOwner;
      uint RegistrationTime;




  }



    function DomainIsRegistered (bytes32 _DomainName) public returns(bool registered){
       for(uint i = 0; i < Domains.length; i++ ){
            if (Domains[i].DomainName == _DomainName && now <= Domains[i].RegistrationTime + 3 minutes  ) //if Domain has been registered before it simply does not register
                return registered = true;
            if (Domains[i].DomainName == _DomainName && now >= Domains[i].RegistrationTime + 3 minutes )
                delete Domains[i];
                return registered = false;
            if (Domains[i].DomainName != _DomainName)
                return registered = false;

        }

    }

    //This function gets arguments from user and register the domain by adding a domian struct to Domians array
    function Register (bytes32 _DomainName) payable public returns(bool success){
        //require(msg.value == 1 ether);
        //payer = msg.sender;
        //if (msg.value < highestBid) throw;
            //if(msg.value != 1 ether) throw;
            //if(!block.coinbase.send(msg.value)) {
                //throw;
            //}
        if (DomainIsRegistered(_DomainName) == false){

            if(msg.value == amount){
                block.coinbase.transfer(amount);
                Domain memory newDomain; //Create a new Domain struct, newDomain, in memory before you add it to an array
                newDomain.DomainName = _DomainName;
                newDomain.DomainOwner = msg.sender;
                newDomain.RegistrationTime = now;
                Domains.push(newDomain); //it changes the states by adding the element to the array

            }
            else {throw;}
        }


        else {throw;}


        return true;
    }

    /*
    function Register (bytes32 _DomainName, bytes32 _DNSHash, bytes32 _TLSKey) public returns(bool success){

        if (DomainIsRegistered(_DomainName) == false){

            Domain memory newDomain; //Create a new Domain struct, newDomain, in memory before you add it to an array
            newDomain.DomainName = _DomainName;
            newDomain.DomainOwner = msg.sender;
            newDomain.RegistrationTime = now;
            newDomain.DNSHash = _DNSHash;
            newDomain.TLSKey = _TLSKey;
            Domains.push(newDomain); //it changes the states by adding the element to the array
        }

        else {throw;}


        return true;
    }*/


    function GetDomain () constant returns  (bytes32[],address[], uint[],bytes32[], bytes32[]) {

        uint length = Domains.length;

        bytes32[] memory DomainNames = new bytes32[](length);
        address[] memory DomainOwners = new address[](length);
        uint[] memory RegistrationTimes = new uint[](length);
        bytes32[] memory DNSHashs = new bytes32[](length);
        bytes32[] memory TLSKeys = new bytes32[](length);

        for(uint i = 0; i < Domains.length; i++ ){
            Domain memory currentDomain;
            currentDomain = Domains[i];
            DomainNames[i] = currentDomain.DomainName;
            DomainOwners[i] = currentDomain.DomainOwner;
            RegistrationTimes[i] = currentDomain.RegistrationTime;
            DNSHashs[i] = currentDomain.DNSHash;
            TLSKeys[i] = currentDomain.TLSKey;
        }
        return(DomainNames,DomainOwners,RegistrationTimes,DNSHashs,TLSKeys);
    }




}
