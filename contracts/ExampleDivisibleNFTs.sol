pragma solidity ^0.4.18;

	/**
     * @title ExampleDivisibleNFTs
     * @dev Exploring the need for a non-fungible token to have multiple owners with different shares
     *
     * @dev A 'unit' in this example is the minimum part of a token that an owner can have.
     * 
     * @notice This is just an example for the Ethereum request for comments section
     * @notice This code is of course UNSAFE & NON SECURE
    */

contract ExampleDivisibleNFTs {

	// ------------------------------ Variables ------------------------------

	// Percentage of ownership over a token  
	mapping(address => mapping(uint => uint)) ownerToTokenShare;

	// How much owners have of a token
	mapping(uint => mapping(address => uint)) tokenToOwnersHoldings;

	// If a token has been created
	mapping(uint => bool) mintedToken;

	// Number of equal(fungible) units that constitute a token (that a token can be divised to)
	uint public divisibility = 1000; // All tokens have the same divisibility in our example

	// total of managed/tracked tokens by this smart contract
	uint public totalSupply;


	// ------------------------------ Modifiers ------------------------------

    modifier onlyNonExistentToken(uint _tokenId) {
        require(mintedToken[_tokenId] == false);
        _;
    }

    modifier onlyExistentToken(uint _tokenId) {
        require(mintedToken[_tokenId] == true);
        _;
    }

	// ------------------------------ View functions ------------------------------

	/// @dev The balance an owner have of a token
	function unitsOwnedOfAToken(address _owner, uint _tokenId) public view returns (uint _balance)
    {
        return ownerToTokenShare[_owner][_tokenId];
    }

	// ------------------------------ Core public functions ------------------------------

	/// @dev Anybody can create a token in our example
	/// @notice Minting grants 100% of the token to a new owner in our example
    function mint(address _owner, uint _tokenId) public onlyNonExistentToken (_tokenId)
    {	
    	mintedToken[_tokenId] = true;

        _addShareToNewOwner(_owner, _tokenId, divisibility); 
        _addNewOwnerHoldingsToToken(_owner, _tokenId, divisibility);

        totalSupply = totalSupply + 1;

        //Minted(_owner, _tokenId); // emit event
    }

	/// @dev transfer parts of a token to another user
    function transfer(address _to, uint _tokenId, uint _units) public onlyExistentToken (_tokenId)
    {
        require(ownerToTokenShare[msg.sender][_tokenId] >= _units);
		// TODO should check _to address to avoid losing tokens units

        _removeShareFromLastOwner(msg.sender, _tokenId, _units);
        _removeLastOwnerHoldingsFromToken(msg.sender, _tokenId, _units);

        _addShareToNewOwner(_to, _tokenId, _units);
        _addNewOwnerHoldingsToToken(_to, _tokenId, _units);

        //Transfer(msg.sender, _to, _tokenId, _units); // emit event
    }

	// ------------------------------ Helper functions (internal functions) ------------------------------

    // Remove token units from last owner
	function _removeShareFromLastOwner(address _owner, uint _tokenId, uint _units) internal
    {
        ownerToTokenShare[_owner][_tokenId] -= _units;
    }

    // Add token units to new owner
	function _addShareToNewOwner(address _owner, uint _tokenId, uint _units) internal
    {
        ownerToTokenShare[_owner][_tokenId] += _units;
    }

    // Remove units from last owner 
	function _removeLastOwnerHoldingsFromToken(address _owner, uint _tokenId, uint _units) internal
    {
        tokenToOwnersHoldings[_tokenId][_owner] -= _units;
    }

    // Add the units to new owner
	function _addNewOwnerHoldingsToToken(address _owner, uint _tokenId, uint _units) internal
    {
        tokenToOwnersHoldings[_tokenId][_owner] += _units;
    }
}