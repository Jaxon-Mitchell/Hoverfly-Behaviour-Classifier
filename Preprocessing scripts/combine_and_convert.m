function combine_and_convert(data, name)
    output = cell(size(data, 1) + 1, size(data, 2));
    dataNames = ["name1", "name2", "name1", "name2", "name1", "name2", "name1", "name2", "name1", "name2", "name1", "name2"];
    [output{1,:}] = deal(dataNames);
    writecell(output, name)
end