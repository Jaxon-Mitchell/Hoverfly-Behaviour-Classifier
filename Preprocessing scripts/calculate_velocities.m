function calculate_velocities(filePath)
    load(filePath, 'DataBlock')
    if size(DataBlock, 2) == 72
        DataBlock = DataBlock + 1;
    end
    writematrix(DataBlock, 'output.csv')
end