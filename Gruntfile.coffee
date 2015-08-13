module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        globalConfig:
            distOutput: 'dist/encodedURI'
            devPort: 12334
            devHost: 'localhost'

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
                    'build/js/fav-list.min.js': 'build/js/fav-list.js'

        htmlbuild:
            dev:
                src: 'html/main.html'
                dest: 'build/devBox/index.html'
                options:
                    beautify: true,
                    scripts:
                        main: 'build/js/*.js'
                    styles:
                        main: 'build/css/style.css'
            dist:
                src: 'html/main.html'
                dest: 'build/combine/main.combine.html'
                options:
                    scripts:
                        main: 'build/js/*.min.js'
                    styles:
                        main: 'build/css/style.css'

        html_minify:
            dist:
                files:
                    'build/min/main.min.html': 'build/combine/main.combine.html'

        encode:
            dist:
                files:
                    '<%= globalConfig.distOutput %>': 'build/min/main.min.html'


        symlink:
            js:
                options:
                    overwrite: yes
                files:
                    'build/js/script.js': 'js/script.js'
                    'build/js/fav-list.js': 'js/fav-list.js'

        connect:
            server:
                options:
                    port: '<%= globalConfig.devPort %>'
                    hostname: '<%= globalConfig.devHost %>'
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

        exec:
            pbcopy: '[[ -e <%= globalConfig.distOutput %> ]] && cat <%= globalConfig.distOutput %> | pbcopy'
            openBrowser: 'open http://<%= globalConfig.devHost %>:<%= globalConfig.devPort %>'

    grunt.loadNpmTasks 'grunt-html-minify'
    grunt.loadNpmTasks 'grunt-html-build'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-symlink'
    grunt.loadNpmTasks 'grunt-contrib-connect'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-jshint'
    grunt.loadNpmTasks 'grunt-contrib-compass'
    grunt.loadNpmTasks 'grunt-exec'

    # load custom tasks
    grunt.loadTasks 'grunt_tasks'

    # define sub-workflows
    grunt.registerTask 'build', [
        'jshint'
        'compass:dev'
        'symlink'
        'htmlbuild:dev'
    ]
    grunt.registerTask 'build_dist', [
        'jshint'
        'compass:dist'
        'symlink'
        'uglify'
        'htmlbuild:dist'
        'html_minify'
    ]

    # define main workflows
    grunt.registerTask 'default', [
        'clean',
        'build',
        'connect',
        'exec:openBrowser'
        'watch'
    ]

    grunt.registerTask 'dist', [
        'clean'
        'build_dist'
        'encode'
        'exec:pbcopy'
    ]

    return
