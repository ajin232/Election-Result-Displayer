//
//  ProcessCSV.swift
//  Election Result Displayer
//
//  Created by Andrew on 5/29/25.
//

import Foundation

func fetchSheets(_ input: String?) async throws -> String {
    // catch invalid input
    if input == nil || input!.count < 40 || !(input!.hasPrefix("https://docs.google.com/spreadsheets/d/")){
        if input != nil && input!.hasPrefix("https://drive.google.com/file/d/"){
            throw AppError.fetchError("invalid address. that is a google drive address, not a google sheets address. open the spreadsheet in google sheets first, and then from there click share.");
        }
        throw AppError.fetchError("invalid address");
    }
    // check for and strip away "/edit..." ending
    var index: String.Index? = input!.range(of: "/edit")?.lowerBound;
    if index == nil{
        // if link does not end with "/edit...", check if it at least ends with "/..."
        let suffix: String = String(input![input!.index(input!.startIndex, offsetBy: 39)...]);
        print(suffix);
        index = suffix.firstIndex(of: "/");
        if index == nil{
            // if it ends with neither, throw error
            throw AppError.fetchError("invalid address. make sure you are copying the link exactly as it is given by google without truncating it.");
        }
        // if it ends with "/...", use that slash as the end delineator and ignore what's after it
        let offset: Int = suffix.distance(from: suffix.startIndex, to: index!);
        index = input!.index(input!.startIndex, offsetBy: (39 + offset));
    }
    // form google csv export url
    let url: URL? = URL(string: (String(input![..<index!]) + "/gviz/tq?tqx=out:csv"));
    if url == nil{
        throw AppError.fetchError("invalid address");
    }
    // try to download csv text from google export url
    let (data, response) = try await URLSession.shared.data(from: url!);
    guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw AppError.fetchError("failed to retrieve data from spreadsheet (could be invalid address, internet problem or that the document is private).");
    }
    // try to write downloaded data into constant csv_as_string
    guard let csv_as_string: String = String(data: data, encoding: .utf8) else{
        throw AppError.fetchError("failed to parse spreadsheet data");
    }
    return csv_as_string;
}

func parseCSVString(pointer: inout Array<Race>, string: String) -> Int{
    // split input string into lines
    let lines: [String.SubSequence] = string.split(whereSeparator: \.isNewline);
    var quotes: Bool;
    var halt: Bool;
    var return2: Bool = false;
    if lines.isEmpty || lines.count < 2{
        // catch invalid files
        print("ERROR");
        return 1;
    } else {
        for i in stride(from: 1, to: lines.count, by: 1){
            // some csv files are formatted "cell 1 data", "cell 2 data", "etc"
            // but others are formatted cell 1 data, cell 2 data, etc
            quotes = false;
            halt = false;
            if lines[i].prefix(1) == "\""{
                // assume that if the line starts with a quotation mark,
                // then the whole line is formatted with quotes
                quotes = true;
            }
            // split the line along the commas into strings representing the columns
            var values = lines[i].components(separatedBy: ",");
            if values.count == 10{ // make sure the row has the right number of columns
                if quotes == true{
                    // if the line was formatted with quotes, strip the quotes from all the columns
                    // temp array to store stripped columns
                    var noquotes: [String] = [String]();
                    for j in stride(from: 0, through: 9, by: 1){
                        if values[j].count < 2{
                            // if for whatever reason one of the columns has only one character,
                            // halt the process for this line and mark the whole line as invalid
                            halt = true;
                            break;
                        }
                        // strip quotes from column and add it to temp array
                        var tempstr: String = String(values[j]);
                        tempstr.removeFirst();
                        tempstr.removeLast();
                        noquotes.append(tempstr);
                    }
                    // replace the values of this line with the no-quotes values
                    values = noquotes;
                }
                if halt == false{
                    // write row data into election data list
                    let temp: Race = Race(racename: values[0], index: i, demname: values[1], dempercent: Float(values[2]) ?? 0, demvotes: Int(values[3]) ?? 0, dempic: values[4], gopname: values[5], goppercent: Float(values[6]) ?? 0, gopvotes: Int(values[7]) ?? 0, goppic: values[8], winner: values[9]);
                    pointer.append(temp);
                } else{
                    print("WARNING: invalid data in row " + String(i));
                    return2 = true;
                }
            } else {
                print("WARNING: invalid data in row " + String(i));
                return2 = true;
            }
        }
    }
    if return2 == true{
        return 2;
    }
    return 0;
}
