varying vec2 coords;
uniform sampler2D texture;

void main() {
    gl_FragColor = texture2D(texture, coords);
    /*gl_FragColor = vec4(1, 0, 0, 1);*/
}
