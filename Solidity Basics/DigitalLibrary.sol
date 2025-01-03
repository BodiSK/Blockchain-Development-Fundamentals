// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

enum Status {
    Active,
    Outdated,
    Archived
}

struct EBook {
    string title;
    string author;
    uint256 publicationDate; //  date to be stored as timestamp
    uint256 expirationDate;
    Status status;
    address primaryLibrarian;
    uint256 readCount;
}

error UnauthorizedLibrarian();
error NonExistantBook();

contract DigitalLibrary {
    mapping (string => EBook) public books;
    mapping (string => address[]) authorizedLibrarians;
    uint256 public defaultExpirationTime = 40;

    function createEbook (string calldata _title, string  calldata _author, uint256 _publicationDate) external {
        books[_title] =
            EBook({
                title: _title,
                author: _author,
                publicationDate: _publicationDate,
                expirationDate: _publicationDate + defaultExpirationTime*(1 days),
                status: Status.Active,
                primaryLibrarian: msg.sender,
                readCount:0
            });
        
    }

    function addLibrarian(address librarian, string calldata title) external {

        if(books[title].primaryLibrarian !=msg.sender) {
            revert UnauthorizedLibrarian();

        }

        authorizedLibrarians[title].push(librarian);
    }

    function extendExpirationDate(string calldata title, uint256 newExpirationDate) external {
        address[] memory librarians = authorizedLibrarians[title];

        bool isAuthorized = false;

        for(uint i =0; i<librarians.length && !isAuthorized; i++) {
            isAuthorized = msg.sender == librarians[i];
        }

        if(!isAuthorized) {
            revert UnauthorizedLibrarian();
        }

        books[title].expirationDate = newExpirationDate;
    }

    function changeStatus(string calldata title, Status newStatus) external {
        if(msg.sender != books[title].primaryLibrarian) {
            revert UnauthorizedLibrarian();
        }

        books[title].status = newStatus;
    }

    function checkExpiration(string calldata title) external {
        Status status = books[title].status;

        if(status != Status.Active || books[title].expirationDate < block.timestamp) {
            revert ("Book is outdated");
        }

        books[title].readCount +=1;
    }


}