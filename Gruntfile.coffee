module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        sass:
            dist:
                options:
                    style: 'expanded'
                    trace: yes
                files:
                    'build/css-noprefix/style.css': 'scss/*.scss'

        autoprefixer:
            dist:
                files: [
                    expand: yes
                    flatten: yes
                    src: 'build/css-noprefix/*.css'
                    dest: 'build/css/'
                ]

        coffee:
            dist:
                files:
                    'build/js/script.js': 'coffee/*.coffee'

        uglify:
            dist:
                files:
                    'build/js/script.min.js': 'build/js/script.js'

        htmlcssjs:
            dev:
                src: ['build/css/style.css', 'build/js/script.js', 'html/main.html']
                dest: 'build/combine/main.combine.html'
            dist:
                src: ['build/css/style.css', 'build/js/script.min.js', 'html/main.html']
                dest: 'build/combine/main.combine.html'

        html_minify:
            dist:
                files:
                    'build/min/main.min.html': 'build/combine/main.combine.html'

        symlink:
            options:
                overwrite: yes
            explicit:
                src: 'build/combine/main.combine.html'
                dest: 'build/devBox/index.html'

        connect:
            server:
                options:
                    port: 12334
                    base: 'build/devBox'
                    livereload: yes

        watch:
            dist:
                files: ['scss/*.scss', 'coffee/*.coffee', 'html/*.html']
                tasks: ['build', 'combine-dev']
                options:
                    livereload: yes


    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-autoprefixer'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-htmlcssjs-combine'
    grunt.loadNpmTasks 'grunt-html-minify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-symlink'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-contrib-uglify'

    grunt.registerTask 'build', ['sass', 'autoprefixer', 'coffee']

    grunt.registerTask 'combine-dev', ['htmlcssjs:dev', 'symlink']
    grunt.registerTask 'combine', ['uglify', 'htmlcssjs:dist', 'html_minify']

    grunt.registerTask 'server', ['connect']

    grunt.registerTask 'default', ['clean', 'build', 'combine-dev', 'server', 'watch']
    grunt.registerTask 'dist', ['clean', 'build', 'combine', 'encode']

    # custom tasks
    grunt.registerTask 'encode', 'Encode the whole html into URI', () ->
        srcURL = 'build/min/main.min.html'
        dstURL = 'dist/encodedURI'
        content = grunt.file.read(srcURL)
        content = 'data:text/html,' + escape content
        grunt.file.write dstURL, content
        grunt.log.oklns "Successfully output encoded URI to file \"#{dstURL}\""
        return

    grunt.registerTask 'clean', 'Clean the build and dist directories', () ->
        buildDir = 'build'
        distDir = 'dist'
        if grunt.file.exists buildDir
            grunt.log.writeln 'Cleaning build directory...'
            grunt.file.delete buildDir
        if grunt.file.exists distDir
            grunt.log.writeln 'Cleaning dist directory...'
            grunt.file.delete distDir

        return

    return
