module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        clean:
            dist:
                targets: ["build", "dist"]

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
                src: [
                    'build/css/style.css',
                    'build/js/script.js',
                    'html/main.html'
                ]
                dest: 'build/devBox/index.html'
            dist:
                src: [
                    'build/css/style.css',
                    'build/js/script.min.js',
                    'html/main.html'
                ]
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
                tasks: ['build']
                options:
                    livereload: yes

        compass:
            dist:
                options:
                    sassDir: 'scss'
                    cssDir: 'build/css'
                    environment: 'production'
            dev:
                options:
                    sassDir: 'scss'
                    cssDir: 'build/css'


    grunt.loadNpmTasks 'grunt-htmlcssjs-combine'
    grunt.loadNpmTasks 'grunt-html-minify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-symlink'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-jshint'
    grunt.loadNpmTasks 'grunt-contrib-compass'

    # load custom tasks
    grunt.loadTasks 'grunt_tasks'

    # define sub-workflows
    grunt.registerTask 'build', [
        'jshint'
        'compass:dev'
        'symlink'
        'htmlcssjs:dev'
    ]

    # define main workflows
    grunt.registerTask 'default', ['clean', 'build', 'connect', 'watch']
    grunt.registerTask 'dist', [
        'clean'
        'jshint'
        'compass:dist'
        'symlink'
        'uglify'
        'htmlcssjs:dist'
        'html_minify'
        'encode'
    ]

    return
