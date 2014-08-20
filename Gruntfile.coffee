module.exports = (grunt) ->
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'
        
        sass:
            dist:
                options:
                    style: 'expanded'
                    # style: 'compressed'
                    trace: yes
                files:
                    'build/css-noprefix/style.css': 'scss/*.scss'

        autoprefixer:
            dist:
                files: [
                    expand: yes
                    flatten: yes
                    src: 'build/css-noprefix/*.css',
                    dest: 'build/css/'
                ]

        coffee:
            compile:
                files:
                    'build/js/script.js': 'coffee/*.coffee'

        htmlcssjs:
            main: {
                src: ['build/css/style.css', 'build/js/script.js', 'html/main.html']
                dest: 'build/combine/main.combine.html'
            }

        html_minify:
            dist:
                files:
                    'build/main.min.html': 'build/combine/main.combine.html'

        watch:
            dist:
                files: ['scss/*.scss', 'coffee/*.coffee', 'html/*.html']
                tasks: ['build', 'combine']
                options:
                    livereload: yes


    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-autoprefixer'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-htmlcssjs-combine'
    grunt.loadNpmTasks 'grunt-html-minify'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.registerTask 'build', ['sass', 'autoprefixer', 'coffee', 'html_minify']
    grunt.registerTask 'combine', ['htmlcssjs', 'html_minify']
    grunt.registerTask 'default', ['build', 'combine', 'watch']

    return
