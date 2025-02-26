// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; //settare la versione di solidity con il ^ dice che va bene anche le versioni superiori di solidity

contract SimpleStorage {
    //Basic Types: boolean, uint(unsigned int) , int , address (address di metamask), bytes
    
    uint256 fav; //se non si mette nulla dopo uint viene messo in automatico 256 
    //uint256 []favList;
    struct Person{
        uint256 favoriteNumber;
        string name;
    }
    //Person public myFriend=Person(7,"Pat");

    Person [] public listOfPeople; //[]

    mapping (string => uint256) public nameToFavoriteNumber;
    //funzione virtuale che quindi puo essere overridata
    function store(uint _fav) public virtual  {
        fav=_fav;
    }
    //view , pure indichiamo che andiamo a leggere lo stato della blockchain 
    //quindi in una funzione di tipo view non è consentito applicare modifiche che comportano
    //modifiche alla blockchain
    function retrieve() public view returns (uint256)
    {
        return fav;
    }
    //calldata, memory, storage (key word che indicano la tipologia di memorizzazione, sono necessarei nelle strutture, stringhe e array)
    function addPerson(string memory _name, uint256 _favNumber) public {
        listOfPeople.push(Person (_favNumber,_name));
        nameToFavoriteNumber[_name]=_favNumber;
    }
}