function ll --description 'List files with details'
    if command -sq eza
        eza -lah --git --group-directories-first $argv
    else
        ls -lah $argv
    end
end

