module.exports = (grunt) ->
    grunt.registerMultiTask 'encode',
        'Encode the whole html into URI',
        () ->
            this.files.forEach (perFile) ->
                content = perFile.src.filter (fp) ->
                    grunt.file.exists fp
                .map (fp) ->
                    return grunt.file.read fp
                .join ''

                if content.length > 0
                    content = "data:text/html," + escape content
                    grunt.file.write perFile.dest, content
                    grunt.log.oklns "Successfully output encoded URI to file \"#{perFile.dest}\""

                return
            return
    return