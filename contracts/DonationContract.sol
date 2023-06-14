// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationContract {
    address volunteer;

    constructor(){
        volunteer = msg.sender;
    }

    struct Donor {
        address donor;
        uint256 id;
        string donorName;
    }

    struct DonationDetail {
        string donationType;
        uint256 campaignId;
        string itemName;
        string itemDescription;
        uint donationAmount;
        bool donationStatus;
    }

    struct Donation {
        Donor donor;
        DonationDetail detail;
    }

    struct Campaign {
        string campaignName;
        string campaignDescription;
        uint maximumDonation;
        bool campaignStatus;
    }

    Donation[] public donations;
    Campaign[] public campaigns;

    function donateBarang(uint256 _campaignId, string memory _donorName, string memory _itemName, string memory _itemDescription) public {
        require(bytes(_donorName).length > 0, "Nama donatur harus diisi");
        require(bytes(_itemName).length > 0, "Nama barang harus diisi");
        require(bytes(_itemDescription).length > 0, "Deskripsi barang harus diisi");
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");

        uint256 id = uint256(keccak256(abi.encodePacked(_donorName, block.timestamp)));

        Donation memory newDonation = Donation(
            Donor(msg.sender, id, _donorName),
            DonationDetail("barang", _campaignId, _itemName, _itemDescription, 0, false)
        );
        donations.push(newDonation);
    }

    function donateUang(uint256 _campaignId, string memory _donorName, uint _donationAmount) public {
        require(bytes(_donorName).length > 0, "Nama donatur harus diisi");
        require(_donationAmount > 0, "Jumlah donasi harus lebih dari 0");
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");

        uint256 id = uint256(keccak256(abi.encodePacked(_donorName, block.timestamp)));

        Donation memory newDonation = Donation(
            Donor(msg.sender, id, _donorName),
            DonationDetail("uang", _campaignId, "", "", _donationAmount, false)
        );
        donations.push(newDonation);
    }

    function createCampaign(string memory _campaignName, string memory _campaignDescription, uint _maximumDonation) public returns (uint256) {
        Campaign memory newCampaign = Campaign(_campaignName, _campaignDescription, _maximumDonation, false);
        campaigns.push(newCampaign);
        return campaigns.length - 1; // Mengembalikan ID kampanye yang baru ditambahkan
    }

    function getDonationsCount(uint _campaignId) public view returns (uint) {
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");
        uint256 length = donations.length;
        uint256 count;
        for (uint256 i = 0; i < length; i++) {
            if (donations[i].detail.campaignId == _campaignId) {
                count++;
            }
        }
        return count;
    }

    function getDonors(uint256 _campaignId) public view returns (address[] memory, uint256[] memory, string[] memory) {
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");

        uint256 count = 0;
        uint256 length = donations.length;
        
        for (uint256 i = 0; i < length; i++) {
            if (donations[i].detail.campaignId == _campaignId && donations[i].donor.donor != address(0)) {
                count++;
            }
        }
        address[] memory donors = new address[](count);
        uint256[] memory ids = new uint256[](count);
        string[] memory donorNames = new string[](count);
        count = 0;
        for (uint256 i = 0; i < length; i++) {
            if (donations[i].detail.campaignId == _campaignId && donations[i].donor.donor != address(0)) {
                donors[count] = donations[i].donor.donor;
                ids[count] = donations[i].donor.id;
                donorNames[count] = donations[i].donor.donorName;
                count++;
            }
        }
        return (donors, ids, donorNames);
    }


    function getDonationDetails(uint256 _campaignId) public view returns (string[] memory, uint256[] memory, string[] memory, string[] memory, uint[] memory, bool[] memory) {
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");
        
        
        uint256 count = 0;
        uint256 length = donations.length;
        
        for (uint256 i = 0; i < length; i++) {
            if (donations[i].detail.campaignId == _campaignId && donations[i].donor.donor != address(0)) {
                count++;
            }
        }
        string[] memory donationTypes = new string[](count);
        uint256[] memory campaignIds = new uint256[](count);
        string[] memory itemNames = new string[](count);
        string[] memory itemDescriptions = new string[](count);
        uint[] memory donationAmounts = new uint[](count);
        bool[] memory donationStatuses = new bool[](count);

        count = 0;
        for (uint256 i = 0; i < length; i++) {
            if (donations[i].detail.campaignId == _campaignId && donations[i].donor.donor != address(0)) {
                donationTypes[count] = donations[i].detail.donationType;
                campaignIds[count] = donations[i].detail.campaignId;
                itemNames[count] = donations[i].detail.itemName;
                itemDescriptions[count] = donations[i].detail.itemDescription;
                donationAmounts[count] = donations[i].detail.donationAmount;
                donationStatuses[count] = donations[i].detail.donationStatus;
                count++;
            }
        }

        return (donationTypes, campaignIds, itemNames, itemDescriptions, donationAmounts, donationStatuses);
    }

    function getVolunteer() public view returns (address){
        return (volunteer);
    }

    function getCampaigns() public view returns (uint256[] memory, string[] memory, string[] memory, uint[] memory, bool[] memory) {
        uint256 length = campaigns.length;
        uint256[] memory campaignIds = new uint256[](length);
        string[] memory campaignNames = new string[](length);
        string[] memory campaignDescriptions = new string[](length);
        uint[] memory   maximumDonations = new uint[](length);
        bool[] memory campaignStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            campaignIds[i] = i;
            campaignNames[i] = campaigns[i].campaignName;
            campaignDescriptions[i] = campaigns[i].campaignDescription;
            campaignStatuses[i] = campaigns[i].campaignStatus;
            maximumDonations[i] = campaigns[i].maximumDonation;
        }

        return (campaignIds, campaignNames, campaignDescriptions, maximumDonations, campaignStatuses);
    }


    function updateDonationStatus(uint256 _id, uint256 _campaignId) public {
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");
        uint256 length = donations.length;
        for (uint256 i = 0; i < length; i++) {
            if (donations[i].donor.id == _id && donations[i].detail.campaignId == _campaignId) {
                donations[i].detail.donationStatus = true;
                return;
            }
        }
        revert("Donasi tidak ditemukan");
    }

    function updateCampaignStatus(uint256 _campaignId) public {
        require(_campaignId < campaigns.length, "ID kampanye tidak valid");
        campaigns[_campaignId].campaignStatus = true;
    }

}