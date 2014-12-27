module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        clean:
            dist:
                targets: ["build", "dist"]

        sass:
            dist:
                options:
                    style: 'expanded'
                    trace: yes
                files:
                    'build/css-noprefix/style.css': 'scss/style.scss'

        autoprefixer:
            dist:
                files: [
                    expand: yes
                    flatten: yes
                    src: 'build/css-noprefix/*.css'
                    dest: 'build/css/'
                ]

        jshint:
            all: [
                'js/**/*.js'
            ]

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

        encode:
            dist:
                files:
                    'dist/encodedURI': 'build/min/main.min.html'


        symlink:
            dist:
                options:
                    overwrite: yes
                files:[
                    'build/devBox/index.html': 'build/combine/main.combine.html'
                ]
            js:
                options:
                    overwrite: yes
                files:[
                    'build/js/script.js': 'js/script.js'
                ]

        connect:
            server:
                options:
                    port: 12334
                    base: 'build/devBox'
                    livereload: yes

        watch:
            dist:
                files: ['scss/*.scss', 'js/**/*.js', 'html/*.html']
                tasks: ['build', 'combine-dev']
                options:
                    livereload: yes


    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-autoprefixer'
    grunt.loadNpmTasks 'grunt-htmlcssjs-combine'
    grunt.loadNpmTasks 'grunt-html-minify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-symlink'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-jshint'

    # load custom tasks
    grunt.loadTasks 'grunt_tasks'

    grunt.registerTask 'build', ['jshint', 'sass', 'autoprefixer', 'symlink:js']

    grunt.registerTask 'combine-dev', ['htmlcssjs:dev', 'symlink']
    grunt.registerTask 'combine', ['uglify', 'htmlcssjs:dist', 'html_minify']

    grunt.registerTask 'server', ['connect']

    grunt.registerTask 'default', ['clean', 'build', 'combine-dev', 'server', 'watch']
    grunt.registerTask 'dist', ['clean', 'build', 'combine', 'encode']

    return
