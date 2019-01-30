pragma solidity ^0.4.0;
contract Test_Domain_Registration_ONE {

    Domain[] public Domains; //Domains is a dynamiclly saized array that has Domain struct inside of it and keeps the state of ll the domains of the contract

    struct Domain{ //Domain struct represents each domain which poseses DomainName, RegistrantName, Validity 
      bytes32 DomainName;
      bytes32 RegistrantName;
      uint RegistrationTime;


  }

    //This function gets arguments from user and register the domain by adding a domian struct to Domians array
    function Register (bytes32 _DomainName, bytes32 _RegistrantName){

        for(uint i = 0; i < Domains.length; i++ ){
            if (Domains[i].DomainName == _DomainName && now <= Domains[i].RegistrationTime + 1 days) //if Domain has been registered && it has not been expired yet >  it  does not register
                throw;
        }

        Domain memory newDomain; //Create a new Domain struct, newDomain, in memory before you add it to an array
        newDomain.DomainName = _DomainName;
        newDomain.RegistrantName = _RegistrantName;
        newDomain.RegistrationTime = now;

        Domains.push(newDomain); //it changes the states by adding the element to the array
    }





    function GetDomain () constant returns  (bytes32[],bytes32[], uint[]) {

        uint length = Domains.length;

        bytes32[] memory DomainNames = new bytes32[](length);
        bytes32[] memory RegistrantNames = new bytes32[](length);
        uint[] memory RegistrationTimes = new uint[](length);

        for(uint i = 0; i < Domains.length; i++ ){
            Domain memory currentDomain;
            currentDomain = Domains[i];
            DomainNames[i] = currentDomain.DomainName;
            RegistrantNames[i] = currentDomain.RegistrantName;
            RegistrationTimes[i] = currentDomain.RegistrationTime;
        }
        return(DomainNames,RegistrantNames,RegistrationTimes);
    }




}
