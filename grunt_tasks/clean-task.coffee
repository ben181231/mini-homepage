module.exports = (grunt) ->
    grunt.registerMultiTask 'clean',
        'Remove directories',
        () ->
            this.requiresConfig("#{this.name}.#{this.target}.targets")

            targets = this.data.targets
            cwd = process.cwd()
            for perTarget in targets
                if grunt.file.exists perTarget
                    grunt.log.writeln "Cleaning: #{cwd}/#{perTarget} ..."
                    grunt.file.delete perTarget

            return
    return