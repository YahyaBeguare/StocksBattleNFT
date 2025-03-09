// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Deploy this contract on Sepolia

// Importing OpenZeppelin contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// Importing Chainlink contracts
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract StocksBattlePriceNFT is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;
    int256 internal BTCVolatility;
    int256 internal ETHVolatility;

    Counters.Counter public tokenIdCounter;

    // https://docs.chain.link/data-feeds/rates-feeds/addresses        

    // Create price feed
       // Sepolia BTC/USD
    AggregatorV3Interface internal bitcoinDayVolatilityFeed= AggregatorV3Interface(
            
            0x28f9134a15cf0aAC9e1F0CD09E17f32925254C77            
        );
    AggregatorV3Interface internal bitcoinWeekVolatilityFeed= AggregatorV3Interface(
            
            0x88163626786Ee98AA1De65BD2A76599e71598FD9            
        );
    AggregatorV3Interface internal bitcoinMonthVolatilityFeed= AggregatorV3Interface(
            
            0xabfe1e28F54Ac40776DfCf2dF0874D37254D5F59            
        );

        // Sepolia ETH/USD
    AggregatorV3Interface internal ethereumDayVolatilityFeed = AggregatorV3Interface(
           
            0x31D04174D0e1643963b38d87f26b0675Bb7dC96e            
        );
    AggregatorV3Interface internal ethereumWeekVolatilityFeed = AggregatorV3Interface(
            
            0xF3140662cE17fDee0A6675F9a511aDbc4f394003            
        );
    AggregatorV3Interface internal ethereumMonthVolatilityFeed = AggregatorV3Interface(
            
            0x8e604308BD61d975bc6aE7903747785Db7dE97e2            
        );

    


    string bitcoinIsCooking = unicode"Bitcoin is cooking ₿ 🔥";
    string ethereumIsCooking = unicode"Ethereum is cooking 💎 🔥";
    string equalVolatility = unicode"₿ 🔥 💎";
    string public priceIndicator;

    struct ChainStruct {
        uint64 code;
        string name;
        string color;
    }
    mapping (uint256 => ChainStruct) chain;

    //https://docs.chain.link/ccip/supported-networks/testnet
    constructor() ERC721("CrossChain Stocks Battle", "CCSB") {
        chain[0] = ChainStruct ({
            code: 16015286601757825753,
            name: "Sepolia",
            color: "#0000ff" //blue
        });
        chain[1] = ChainStruct ({
            code: 14767482510784806043,
            name: "Fuji",
            color: "#ff0000" //red
        });
        chain[2] = ChainStruct ({
            code: 10344971235874465080,
            name: "Base Sepolia",
            color: "#ffffff" //black
        });
        chain[3] = ChainStruct ({
            code: 10344971235874465080,
            name: "Polygon Amoy",
            color: "#4b006e" //purple
        });

        
        priceIndicator = unicode"₿ and 💎";

        // Mint an NFT
        mint(msg.sender, 0, 1);
    }

    function mint(address to, uint256 _sourceId, uint256 _period) public {
        // Mint from Sepolia network = chain[0]
        mintFrom(to, _sourceId, _period);
    }

    function mintFrom(address to, uint256 sourceId, uint256 _period) public {
        // sourceId 0 Sepolia, 1 Fuji, 2 Mumbai
        uint256 tokenId = tokenIdCounter.current();
        _safeMint(to, tokenId);
        updateMetaData(tokenId, sourceId, _period);    
        tokenIdCounter.increment();
    }

    // Update MetaData
    function updateMetaData(uint256 tokenId, uint256 sourceId, uint256 _period) public {
        // Create the SVG string
        string memory finalSVG = buildSVG(sourceId, _period);
           
        // Base64 encode the SVG
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Cross-chain Price SVG",',
                        '"description": "SVG NFTs in different chains",',
                        '"image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSVG)), '",',
                        '"attributes": [',
                            '{"trait_type": "source",',
                            '"value": "', chain[sourceId].name ,'"},',
                            '{"trait_type": "Ethereum volatility",',
                            '"value": "', ETHVolatility ,'"}',
                            '{"trait_type": "Bitcoin volatility",',
                            '"value": "', BTCVolatility ,'"}',
                        ']}'
                    )
                )
            )
        );
        // Create token URI
        string memory finalTokenURI = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        // Set token URI
        _setTokenURI(tokenId, finalTokenURI);
    }

    // Build the SVG string
    function buildSVG(uint256 sourceId, uint256 _period) internal returns (string memory) {

        // Create SVG rectangle with random color
        string memory headSVG = string(
            abi.encodePacked(
                "<svg xmlns='http://www.w3.org/2000/svg' version='1.1' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:svgjs='http://svgjs.com/svgjs' width='500' height='500' preserveAspectRatio='none' viewBox='0 0 500 500'> <rect width='100%' height='100%' fill='",
                chain[sourceId].color,
                "' />"
            )
        );
        // Update emoji based on price
        string memory bodySVG = string(
            abi.encodePacked(
                "<text x='50%' y='50%' font-size='128' dominant-baseline='middle' text-anchor='middle'>",
                compareVolatility(_period),
                "</text>"
            )
        );
        // Close SVG
        string memory tailSVG = "</svg>";

        // Concatenate SVG strings
        string memory _finalSVG = string(
            abi.encodePacked(headSVG, bodySVG, tailSVG)
        );
        return _finalSVG;
    }

    // Compare new price to previous price
    function compareVolatility(uint256 _period) public returns (string memory) {
       
        
        int256 btcVolatility ;
        int256 ethVolatility ;
        (btcVolatility, ethVolatility) = getVolatilityFeedLatestAnswer(_period);
        
        BTCVolatility = btcVolatility;
        ETHVolatility = ethVolatility;
        if (btcVolatility > ethVolatility) {
            priceIndicator = bitcoinIsCooking;
        } else if (btcVolatility < ethVolatility) {
            priceIndicator = ethereumIsCooking;
        } else {
            priceIndicator = equalVolatility;
        }
        return priceIndicator;
    }

    function getVolatilityFeedLatestAnswer(uint256 _period) public view returns (int256 btcVolatility, int256 ethVolatility) {
               
        if(_period == 1){
            
            (, btcVolatility, , , ) = bitcoinDayVolatilityFeed.latestRoundData();
            (, ethVolatility, , , ) = ethereumDayVolatilityFeed.latestRoundData();
        } else if(_period == 7){
            
            (, btcVolatility, , , ) = bitcoinWeekVolatilityFeed.latestRoundData();
            (, ethVolatility, , , ) = ethereumWeekVolatilityFeed.latestRoundData();
        } else if(_period == 30){
            
            (, btcVolatility, , , ) = bitcoinMonthVolatilityFeed.latestRoundData();
            (, ethVolatility, , , ) = ethereumMonthVolatilityFeed.latestRoundData();
        }
        return (btcVolatility, ethVolatility);

    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    // The following function is an override required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }
}