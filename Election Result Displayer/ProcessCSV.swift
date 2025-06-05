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
        throw AppError.fetchError("invalid address");
    }
    // check for and then strip away "/edit" ending
    let index: String.Index? = input!.range(of: "/edit")?.lowerBound;
    if index == nil{
        // link without "/edit" could technically be valid but it's easier
        // to just throw out anything that doesnt have it
        throw AppError.fetchError("invalid address");
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
        throw AppError.fetchError("failed to retrieve data from spreadsheet (either invalid address or internet/google problem)");
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
    // this is what delineates the boundary between two cells
    var seperator: String = "\",\"";
    var quotes: Bool = true;
    if lines.isEmpty || lines.count < 2{
        // catch invalid files
        print("ERROR");
        return 1;
    } else {
        // some csv files are formatted "cell 1 data", "cell 2 data", "etc"
        // but others are formatted cell 1 data, cell 2 data, etc
        // if is the latter, change the seperator variable to not look for quotation marks
        if lines[1].prefix(1) != "\""{
            seperator = ","
            quotes = false;
        }
        for i in stride(from: 1, to: lines.count, by: 1){
            let values = lines[i].split(separator: seperator);
            var index0 = values[0];
            var index9 = values[9];
            if quotes == true{
                index0.removeFirst();
                index9.removeLast();
            }
            if values.count == 10{ // make sure the row has the right number of columns
                // write row data into election data list
                let temp: Race = Race(racename: String(index0), index: i, demname: String(values[1]), dempercent: Float(values[2]) ?? 0, demvotes: Int(values[3]) ?? 0, dempic: String(values[4]), gopname: String(values[5]), goppercent: Float(values[6]) ?? 0, gopvotes: Int(values[7]) ?? 0, goppic: String(values[8]), winner: String(index9));
                pointer.append(temp);
            } else {
                print("WARNING: invalid data in row " + String(i));
            }
        }
    }
    return 0;
}
