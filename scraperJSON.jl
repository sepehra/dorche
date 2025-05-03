using HTTP, JSON3

function saferm()
    try
        rm("prices.JSON")
    catch e
        @warn "Failed to delete $path: $e"
    end
end

saferm()

function main()

api_url = "https://www.tala.ir/banner/?ids=1001,&is-mobile=0"
headers = [
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
]

response = HTTP.get(api_url; headers=headers)
json_str = String(response.body)

# Parse JSON
data = JSON3.read(json_str)

# Extract the "price" object
price_obj = data.price  # Now works!

# Create the dictionary
price_data = Dict(
    "ounce" => price_obj[:ounce],
    "bazartehran" => price_obj[:bazartehran],
    "geram18" => price_obj[:geram18],
    "sekkejad" => price_obj[:sekkejad],
    "sekkenim" => price_obj[:sekkenim],
    "sekkerob" => price_obj[:sekkerob],
    "parsian1" => price_obj[:parsian1],
    "shemsh1" => price_obj[:shemsh1],
    "BTC_USDT" => price_obj[:BTC_USDT],
    "sekke-arzesh" => price_obj[Symbol("sekke-arzesh")],  # Handle hyphenated key
    "ENERGY_BRENT" => price_obj[:ENERGY_BRENT],
    "USDT_IRT" => price_obj[:USDT_IRT]
)

# Print results (keys remain strings for readability)
for (k, v) in price_data
    println("$k => $v")
end

function JSON_writer()
    # Open file for writing
    file = open("prices.JSON", "w")
    
    # Start the JSON object
    write(file, "{\n")
    
    # Iterate over the price_data and write key-value pairs
    for (i, (k, v)) in enumerate(price_data)
        write(file, "\t")
        write(file, "\"$k\": \"$v\"")
        
        # Add a comma unless it's the last element
        if i < length(price_data)
            write(file, ",\n")
        else
            write(file, "\n")
        end
    end
    
    # End the JSON object
    write(file, "}")
    
    # Close the file
    close(file)
end

JSON_writer()
end # main()

while true
    try
        main()
        break
    catch e
        @warn "Error: $e — retrying..."
        sleep(2.5)
    end
end