#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 32, local_size_y = 1, local_size_z = 1) in;

//Input variables (format: in type in_variable_name;)
layout(set = 0, binding = 0, std430) restrict buffer InputBuffer {
    ivec2 inputs[]; // Array of vec2s for input
} input_buffer;

//Output variables (format: out type out_variable_name;)
layout(set = 0, binding = 1, std430) restrict buffer OutputBuffer {
    float outputs[]; // Array of floats for output
} output_buffer;

//Uniforms
layout(set = 0, binding = 2, std430) restrict buffer ConstantsBuffer {
    float STRETCH_CONSTANT4;
    float SQUISH_CONSTANT4;
    float lacunarity;
    float persistence;
} constants;

layout(set = 0, binding = 3, std430) restrict buffer IntConstantBlock {
    int NORM_CONSTANT4;
    int octaves;
    int period;
} int_constants;

layout(set = 0, binding = 4, std430) restrict buffer GradientBlock {
    int GRADIENTS4[];
} gradients;

layout(set = 0, binding = 5, std430) restrict buffer PermBlock {
    int perm[];
} perm;

const float TAU = 6.283185;

//Helper function definitions
float extrapolate4(float xsb, float ysb, float zsb, float wsb, float dx, float dy, float dz, float dw) {
    int xsb_int = int(xsb) & 0xFF;
    int ysb_int = int(ysb) & 0xFF;
    int zsb_int = int(zsb) & 0xFF;
    int wsb_int = int(wsb) & 0xFF;
    int index = perm.perm[(perm.perm[(perm.perm[(perm.perm[xsb_int] + ysb_int) & 0xFF] + zsb_int) & 0xFF] + wsb_int) & 0xFF] & 0xFC;
    int g1 = gradients.GRADIENTS4[index];
    int g2 = gradients.GRADIENTS4[index + 1];
    int g3 = gradients.GRADIENTS4[index + 2];
    int g4 = gradients.GRADIENTS4[index + 3];
    float result = ((g1 * dx) + (g2 * dy) + (g3 * dz) + (g4 * dw));
    return result;
}

float single_noise4(float x, float y, float z, float w) {
    //Define all needed variables for the rest of the function
    //The value to be returned
    float value;
    //Offsets
    float stretch_offset;
    float squish_offset;
    //*s
    float xs;
    float ys;
    float zs;
    float ws;
    //*sb
    float xsb;
    float ysb;
    float zsb;
    float wsb;
    //*b
    float xb;
    float yb;
    float zb;
    float wb;
    //*ins
    float xins;
    float yins;
    float zins;
    float wins;
    //in_sum
    float in_sum;
    //a_po
    int a_po;
    //a_score
    float a_score;
    //a_is_bigger_side
    bool a_is_bigger_side;
    //attn0-attn10
    float attn0;
    float attn1;
    float attn2;
    float attn3;
    float attn4;
    float attn5;
    float attn6;
    float attn7;
    float attn8;
    float attn9;
    float attn10;
    //attn_ext0-attn_ext2
    float attn_ext0;
    float attn_ext1;
    float attn_ext2;
    //b_po
    int b_po;
    //b_score
    float b_score;
    //b_is_bigger_side
    bool b_is_bigger_side;
    //c-c2
    int c;
    int c1;
    int c2;
    //d*0-d*10
    float dx0;
    float dx1;
    float dx2;
    float dx3;
    float dx4;
    float dx5;
    float dx6;
    float dx7;
    float dx8;
    float dx9;
    float dx10;
    float dy0;
    float dy1;
    float dy2;
    float dy3;
    float dy4;
    float dy5;
    float dy6;
    float dy7;
    float dy8;
    float dy9;
    float dy10;
    float dz0;
    float dz1;
    float dz2;
    float dz3;
    float dz4;
    float dz5;
    float dz6;
    float dz7;
    float dz8;
    float dz9;
    float dz10;
    float dw0;
    float dw1;
    float dw2;
    float dw3;
    float dw4;
    float dw5;
    float dw6;
    float dw7;
    float dw8;
    float dw9;
    float dw10;
    //d*_ext0-d*_ext2
    float dx_ext0;
    float dx_ext1;
    float dx_ext2;
    float dy_ext0;
    float dy_ext1;
    float dy_ext2;
    float dz_ext0;
    float dz_ext1;
    float dz_ext2;
    float dw_ext0;
    float dw_ext1;
    float dw_ext2;
    //p1-p4
    float p1;
    float p2;
    float p3;
    float p4;
    //score
    float score;
    //uins
    float uins;
    //*sv_ext0-*sv_ext2
    float xsv_ext0;
    float xsv_ext1;
    float xsv_ext2;
    float ysv_ext0;
    float ysv_ext1;
    float ysv_ext2;
    float zsv_ext0;
    float zsv_ext1;
    float zsv_ext2;
    float wsv_ext0;
    float wsv_ext1;
    float wsv_ext2;
    //Place input coordinates on simplectic honeycomb.
    stretch_offset = (x + y + z + w) * constants.STRETCH_CONSTANT4;
    xs = x + stretch_offset;
    ys = y + stretch_offset;
    zs = z + stretch_offset;
    ws = w + stretch_offset;
    //Floor to get simplectic honeycomb coordinates of rhombo-hypercube super-cell origin.
    xsb = floor(xs);
    ysb = floor(ys);
    zsb = floor(zs);
    wsb = floor(ws);
    //Skew out to get actual coordinates of stretched rhombo-hypercube origin. We'll need these later.
    squish_offset = (xsb + ysb + zsb + wsb) * constants.SQUISH_CONSTANT4;
    xb = xsb + squish_offset;
    yb = ysb + squish_offset;
    zb = zsb + squish_offset;
    wb = wsb + squish_offset;
    //Compute simplectic honeycomb coordinates relative to rhombo-hypercube origin.
    xins = xs - xsb;
    yins = ys - ysb;
    zins = zs - zsb;
    wins = ws - wsb;
    //Sum those together to get a value that determines which region we're in.
    in_sum = xins + yins + zins + wins;
    //Positions relative to origin po.
    dx0 = x - xb;
    dy0 = y - yb;
    dz0 = z - zb;
    dw0 = w - wb;
    value = 0;
    if (in_sum <= 1) { //We're inside the pentachoron (4-Simplex) at (0,0,0,0)
        //Determine which two of (0,0,0,1), (0,0,1,0), (0,1,0,0), (1,0,0,0) are closest.
        a_po = 0x01;
        a_score = xins;
        b_po = 0x02;
        b_score = yins;
        if (a_score >= b_score && zins > b_score) {
            b_score = zins;
            b_po = 0x04;
        }
        else if (a_score < b_score && zins > a_score) {
            a_score = zins;
            a_po = 0x04;
        }
        if (a_score >= b_score && wins > b_score) {
            b_score = wins;
            b_po = 0x08;
        }
        else if (a_score < b_score && wins > a_score) {
            a_score = wins;
            a_po = 0x08;
        }
        //Now we determine the three lattice pos not part of the pentachoron that may contribute.
        //This depends on the closest two pentachoron vertices, including (0,0,0,0)
        uins = 1 - in_sum;
        if (uins > a_score || uins > b_score) { //(0,0,0,0) is one of the closest two pentachoron vertices.
            c = (b_score > a_score) ? b_po : a_po; //Our other closest vertex is the closest out of a and b.
            if ((c & 0x01) == 0) {
                xsv_ext0 = xsb - 1;
                xsv_ext1 = xsb;
                xsv_ext2 = xsb;
                dx_ext0 = dx0 + 1;
                dx_ext1 = dx0;
                dx_ext2 = dx0;
            }
            else {
                xsv_ext0 = xsb + 1;
                xsv_ext1 = xsb + 1;
                xsv_ext2 = xsb + 1;
                dx_ext0 = dx0 - 1;
                dx_ext1 = dx0 - 1;
                dx_ext2 = dx0 - 1;
            }
            if ((c & 0x02) == 0) {
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                ysv_ext2 = ysb;
                dy_ext0 = dy0;
                dy_ext1 = dy0;
                dy_ext2 = dy0;
                if ((c & 0x01) == 0x01) {
                    ysv_ext0 -= 1;
                    dy_ext0 += 1;
                }
                else {
                    ysv_ext1 -= 1;
                    dy_ext1 += 1;
                }
            }
            else {
                ysv_ext0 = ysb + 1;
                ysv_ext1 = ysb + 1;
                ysv_ext2 = ysb + 1;
                dy_ext0 = dy0 - 1;
                dy_ext1 = dy0 - 1;
                dy_ext2 = dy0 - 1;
            }
            if ((c & 0x04) == 0) {
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                zsv_ext2 = zsb;
                dz_ext0 = dz0;
                dz_ext1 = dz0;
                dz_ext2 = dz0;
                if ((c & 0x03) != 0) {
                    if ((c & 0x03) == 0x03) {
                        zsv_ext0 -= 1;
                        dz_ext0 += 1;
                    }
                    else {
                        zsv_ext1 -= 1;
                        dz_ext1 += 1;
                    }
                }
                else {
                    zsv_ext2 -= 1;
                    dz_ext2 += 1;
                }
            }
            else {
                zsv_ext0 = zsb + 1;
                zsv_ext1 = zsb + 1;
                zsv_ext2 = zsb + 1;
                dz_ext0 = dz0 - 1;
                dz_ext1 = dz0 - 1;
                dz_ext2 = dz0 - 1;
            }
            if ((c & 0x08) == 0) {
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                wsv_ext2 = wsb - 1;
                dw_ext0 = dw0;
                dw_ext1 = dw0;
                dw_ext2 = dw0 + 1;
            }
            else {
                wsv_ext0 = wsb + 1;
                wsv_ext1 = wsb + 1;
                wsv_ext2 = wsb + 1;
                dw_ext0 = dw0 - 1;
                dw_ext1 = dw0 - 1;
                dw_ext2 = dw0 - 1;
            }
        }
        else { //(0,0,0,0) is not one of the closest two pentachoron vertices
            c = a_po | b_po; //Our three extra vertices are determined by the closest two
            if ((c & 0x01) == 0) {
                xsv_ext0 = xsb;
                xsv_ext2 = xsb;
                xsv_ext1 = xsb - 1;
                dx_ext0 = dx0 - 2 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 + 1 - constants.SQUISH_CONSTANT4;
                dx_ext2 = dx0 - constants.SQUISH_CONSTANT4;
            }
            else {
                xsv_ext0 = xsb + 1;
                xsv_ext1 = xsb + 1;
                xsv_ext2 = xsb + 1;
                dx_ext0 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 1 - constants.SQUISH_CONSTANT4;
                dx_ext2 = dx0 - 1 - constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x02) == 0) {
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                ysv_ext2 = ysb;
                dy_ext0 = dy0 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - constants.SQUISH_CONSTANT4;
                if ((c & 0x01) == 0x01) {
                    ysv_ext1 -= 1;
                    dy_ext1 += 1;
                }
                else {
                    ysv_ext2 -= 1;
                    dy_ext2 += 1;
                }
            }
            else {
                ysv_ext0 = ysb + 1;
                ysv_ext1 = ysb + 1;
                ysv_ext2 = ysb + 1;
                dy_ext0 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 1 - constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 1 - constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x04) == 0) {
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                zsv_ext2 = zsb;
                dz_ext0 = dz0 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - constants.SQUISH_CONSTANT4;
                if ((c & 0x03) == 0x03) {
                    zsv_ext1 -= 1;
                    dz_ext1 += 1;
                }
                else {
                    zsv_ext2 -= 1;
                    dz_ext2 += 1;
                }
            }
            else {
                zsv_ext0 = zsb + 1;
                zsv_ext1 = zsb + 1;
                zsv_ext2 = zsb + 1;
                dz_ext0 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 1 - constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 1 - constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x08) == 0) {
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                wsv_ext2 = wsb - 1;
                dw_ext0 = dw0 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 + 1 - constants.SQUISH_CONSTANT4;
            }
            else {
                wsv_ext0 = wsb + 1;
                wsv_ext1 = wsb + 1;
                wsv_ext2 = wsb + 1;
                dw_ext0 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 1 - constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 1 - constants.SQUISH_CONSTANT4;
            }
        }
        //Contribution (0,0,0,0)
        attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0 - dw0 * dw0;
        if (attn0 > 0) {
            attn0 *= attn0;
            value += attn0 * attn0 * (extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 0.0), (wsb + 0.0), dx0, dy0, dz0, dw0));
        }
        //Contribution (1,0,0,0)
        dx1 = dx0 - 1 - constants.SQUISH_CONSTANT4;
        dy1 = dy0 - 0 - constants.SQUISH_CONSTANT4;
        dz1 = dz0 - 0 - constants.SQUISH_CONSTANT4;
        dw1 = dw0 - 0 - constants.SQUISH_CONSTANT4;
        attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
        if (attn1 > 0) {
            attn1 *= attn1;
            value += attn1 * attn1 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 0.0), (wsb + 0.0), dx1, dy1, dz1, dw1);
        }
        //Contribution (0,1,0,0)
        dx2 = dx0 - 0 - constants.SQUISH_CONSTANT4;
        dy2 = dy0 - 1 - constants.SQUISH_CONSTANT4;
        dz2 = dz1;
        dw2 = dw1;
        attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
        if (attn2 > 0) {
            attn2 *= attn2;
            value += attn2 * attn2 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 0.0), (wsb + 0.0), dx2, dy2, dz2, dw2);
        }
        //Contribution (0,0,1,0)
        dx3 = dx2;
        dy3 = dy1;
        dz3 = dz0 - 1 - constants.SQUISH_CONSTANT4;
        dw3 = dw1;
        attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
        if (attn3 > 0) {
            attn3 *= attn3;
            value += attn3 * attn3 * extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 1.0), (wsb + 0.0), dx3, dy3, dz3, dw3);
        }
        //Contribution (0,0,0,1)
        dx4 = dx2;
        dy4 = dy1;
        dz4 = dz1;
        dw4 = dw0 - 1 - constants.SQUISH_CONSTANT4;
        attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
        if (attn4 > 0) {
            attn4 *= attn4;
            value += attn4 * attn4 * extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 0.0), (wsb + 1.0), dx4, dy4, dz4, dw4);
        }
    }
    else if (in_sum >= 3) { //We're inside the pentachoron (4-Simplex) at (1,1,1,1)
        //Determine which two of (1,1,1,0), (1,1,0,1), (1,0,1,1), (0,1,1,1) are closest
        a_po = 0x0E;
        a_score = xins;
        b_po = 0x0D;
        b_score = yins;
        if (a_score <= b_score && zins < b_score) {
            b_score = zins;
            b_po = 0x0B;
        }
        else if (a_score > b_score && zins < a_score) {
            a_score = zins;
            a_po = 0x0B;
        }
        if (a_score <= b_score && wins < b_score) {
            b_score = wins;
            b_po = 0x07;
        }
        else if (a_score > b_score && wins < a_score) {
            a_score = wins;
            a_po = 0x07;
        }
        //Now we determine the three lattice pos not part of the pentachoron that may contribute
        //This depends on the closst two pentachoron vertices, including (0,0,0,0)
        uins = 4 - in_sum;
        if (uins < a_score || uins < b_score) { //(1,1,1,1) is one of the closest two pentachoron vertices
            c = (b_score < a_score) ? b_po : a_po;
            if ((c & 0x01) != 0) {
                xsv_ext0 = xsb + 2;
                xsv_ext1 = xsb + 1;
                xsv_ext2 = xsb + 1;
                dx_ext0 = dx0 - 2 - 4 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dx_ext2 = dx0 - 1 - 4 * constants.SQUISH_CONSTANT4;
            }
            else {
                xsv_ext0 = xsb;
                xsv_ext1 = xsb;
                xsv_ext2 = xsb;
                dx_ext0 = dx0 - 4 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 4 * constants.SQUISH_CONSTANT4;
                dx_ext2 = dx0 - 4 * constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x02) != 0) {
                ysv_ext0 = ysb + 1;
                ysv_ext1 = ysb + 1;
                ysv_ext2 = ysb + 1;
                dy_ext0 = dy0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                if ((c & 0x01) != 0) {
                    ysv_ext1 += 1;
                    dy_ext1 -= 1;
                }
                else {
                    ysv_ext0 += 1;
                    dy_ext0 -= 1;
                }
            }
            else {
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                ysv_ext2 = ysb;
                dy_ext0 = dy0 - 4 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 4 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 4 * constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x04) != 0) {
                zsv_ext0 = zsb + 1;
                zsv_ext1 = zsb + 1;
                zsv_ext2 = zsb + 1;
                dz_ext0 = dz0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                if ((c & 0x03) != 0x03) {
                    if ((c & 0x03) == 0) {
                        zsv_ext0 += 1;
                        dz_ext0 -= 1;
                    }
                    else {
                        zsv_ext1 += 1;
                        dz_ext1 -= 1;
                    }
                }
                else {
                    zsv_ext2 += 1;
                    dz_ext2 -= 1;
                }
            }
            else {
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                zsv_ext2 = zsb;
                dz_ext0 = dz0 - 4 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 4 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 4 * constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x08) != 0) {
                wsv_ext0 = wsb + 1;
                wsv_ext1 = wsb + 1;
                wsv_ext2 = wsb + 2;
                dw_ext0 = dw0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 2 - 4 * constants.SQUISH_CONSTANT4;
            }
            else {
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                wsv_ext2 = wsb;
                dw_ext0 = dw0 - 4 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 4 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 4 * constants.SQUISH_CONSTANT4;
            }
        }
        else { //(1,1,1,1) is not one of the closest two pentachoron vertices
            c = a_po & b_po; //Our three extra vertices are determined by the closest two
            if ((c & 0x01) != 0) {
                xsv_ext0 = xsb + 1;
                xsv_ext2 = xsb + 1;
                xsv_ext1 = xsb + 2;
                dx_ext0 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 2 - 3 * constants.SQUISH_CONSTANT4;
                dx_ext2 = dx0 - 1 - 3 * constants.SQUISH_CONSTANT4;
            }
            else {
                xsv_ext0 = xsb;
                xsv_ext1 = xsb;
                xsv_ext2 = xsb;
                dx_ext0 = dx0 - 2 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 3 * constants.SQUISH_CONSTANT4;
                dx_ext2 = dx0 - 3 * constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x02) != 0) {
                ysv_ext0 = ysb + 1;
                ysv_ext1 = ysb + 1;
                ysv_ext2 = ysb + 1;
                dy_ext0 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                if ((c & 0x01) != 0) {
                    ysv_ext2 += 1;
                    dy_ext2 -= 1;
                }
                else {
                    ysv_ext1 += 1;
                    dy_ext1 -= 1;
                }
            }
            else {
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                ysv_ext2 = ysb;
                dy_ext0 = dy0 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 3 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 3 * constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x04) != 0) {
                zsv_ext0 = zsb + 1;
                zsv_ext1 = zsb + 1;
                zsv_ext2 = zsb + 1;
                dz_ext0 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                if ((c & 0x03) != 0) {
                    zsv_ext2 += 1;
                    dz_ext2 -= 1;
                }
                else {
                    zsv_ext1 += 1;
                    dz_ext1 -= 1;
                }
            }
            else {
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                zsv_ext2 = zsb;
                dz_ext0 = dz0 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 3 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 3 * constants.SQUISH_CONSTANT4;
            }
            if ((c & 0x08) != 0) {
                wsv_ext0 = wsb + 1;
                wsv_ext1 = wsb + 1;
                wsv_ext2 = wsb + 2;
                dw_ext0 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 2 - 3 * constants.SQUISH_CONSTANT4;
            }
            else {
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                wsv_ext2 = wsb;
                dw_ext0 = dw0 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 3 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 3 * constants.SQUISH_CONSTANT4;
            }
        }
        //Contribution (1,1,1,0)
        dx4 = dx0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        dy4 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        dz4 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        dw4 = dw0 - 3 * constants.SQUISH_CONSTANT4;
        attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
        if (attn4 > 0) {
            attn4 *= attn4;
            value += attn4 * attn4 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 1.0), (wsb + 0.0), dx4, dy4, dz4, dw4);
        }
        //Contribution (1,1,0,1)
        dx3 = dx4;
        dy3 = dy4;
        dz3 = dz0 - 3 * constants.SQUISH_CONSTANT4;
        dw3 = dw0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
        if (attn3 > 0) {
            attn3 *= attn3;
            value += attn3 * attn3 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 0.0), (wsb + 1.0), dx3, dy3, dz3, dw3);
        }
        //Contribution (1,0,1,1)
        dx2 = dx4;
        dy2 = dy0 - 3 * constants.SQUISH_CONSTANT4;
        dz2 = dz4;
        dw2 = dw3;
        attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
        if (attn2 > 0) {
            attn2 *= attn2;
            value += attn2 * attn2 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 1.0), (wsb + 1.0), dx2, dy2, dz2, dw2);
        }
        //Contribution (0,1,1,1)
        dx1 = dx0 - 3 * constants.SQUISH_CONSTANT4;
        dz1 = dz4;
        dy1 = dy4;
        dw1 = dw3;
        attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
        if (attn1 > 0) {
            attn1 *= attn1;
            value += attn1 * attn1 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 1.0), (wsb + 1.0), dx1, dy1, dz1, dw1);
        }
        //Contribution (1,1,1,1)
        dx0 = dx0 - 1 - 4 * constants.SQUISH_CONSTANT4;
        dy0 = dy0 - 1 - 4 * constants.SQUISH_CONSTANT4;
        dz0 = dz0 - 1 - 4 * constants.SQUISH_CONSTANT4;
        dw0 = dw0 - 1 - 4 * constants.SQUISH_CONSTANT4;
        attn0 = 2 - dx0 * dx0 - dy0 * dy0 - dz0 * dz0 - dw0 * dw0;
        if (attn0 > 0) {
            attn0 *= attn0;
            value += attn0 * attn0 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 1.0), (wsb + 1.0), dx0, dy0, dz0, dw0);
        }
    }
    else if (in_sum <= 2) { //We're inside the first dispentachoron (Rectified 4-Simplex)
        a_is_bigger_side = true;
        b_is_bigger_side = true;
        a_po = 0x0E;
        a_score = xins;
        b_po = 0x0D;
        b_score = yins;
        //Decide between (1,1,0,0) and (0,0,1,1)
        if ((xins + yins) > (zins + wins)) {
            a_score = xins + yins;
            a_po = 0x03;
        }
        else {
            a_score = zins + wins;
            a_po = 0x0C;
        }
        //Decide between (1,0,1,0) and (0,1,0,1)
        if ((xins + zins) > (yins + wins)) {
            b_score = xins + zins;
            b_po = 0x05;
        }
        else {
            b_score = yins + wins;
            b_po = 0x0A;
        }
        //Closer between (1,0,0,1) and (0,1,1,0) will replace the further of a and b, if closer
        if ((xins + wins) > (yins + zins)) {
            score = xins + wins;
            if (a_score >= b_score && score > b_score) {
                b_score = score;
                b_po = 0x09;
            }
            else if (a_score < b_score && score > a_score) {
                a_score = score;
                a_po = 0x09;
            }
        }
        else {
            score = yins + zins;
            if (a_score >= b_score && score > b_score) {
                b_score = score;
                b_po = 0x06;
            }
            else if (a_score < b_score && score > a_score) {
                a_score = score;
                a_po = 0x06;
            }
        }
        //Decide if (1,0,0,0) is closer
        p1 = 2 - in_sum + xins;
        if (a_score >= b_score && p1 > b_score) {
            b_score = p1;
            b_po = 0x01;
            b_is_bigger_side = false;
        }
        else if (a_score < b_score && p1 > a_score) {
            a_score = p1;
            a_po = 0x01;
            a_is_bigger_side = false;
        }
        //Decide if (0,1,0,0) is closer
        p2 = 2 - in_sum + yins;
        if (a_score >= b_score && p2 > b_score) {
            b_score = p2;
            b_po = 0x02;
            b_is_bigger_side = false;
        }
        else if (a_score < b_score && p2 > a_score) {
            a_score = p2;
            a_po = 0x02;
            a_is_bigger_side = false;
        }
        //Decide if (0,0,1,0) is closer
        p3 = 2 - in_sum + zins;
        if (a_score >= b_score && p3 > b_score) {
            b_score = p3;
            b_po = 0x04;
            b_is_bigger_side = false;
        }
        else if (a_score < b_score && p3 > a_score) {
            a_score = p3;
            a_po = 0x04;
            a_is_bigger_side = false;
        }
        //Decide if (0,0,0,1) is closer
        p4 = 2 - in_sum + wins;
        if (a_score >= b_score && p4 > b_score) {
            b_po = 0x08;
            b_is_bigger_side = false;
        }
        else if (a_score < b_score && p4 > a_score) {
            a_po = 0x08;
            a_is_bigger_side = false;
        }
        //Where each of the two closest pos are determines how the extra three vertices are calculated
        if (a_is_bigger_side == b_is_bigger_side) {
            if (a_is_bigger_side) {
                c1 = a_po | b_po;
                c2 = a_po & b_po;
                if ((c1 & 0x01) == 0) {
                    xsv_ext0 = xsb;
                    xsv_ext1 = xsb - 1;
                    dx_ext0 = dx0 - 3 * constants.SQUISH_CONSTANT4;
                    dx_ext1 = dx0 + 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                else {
                    xsv_ext0 = xsb + 1;
                    xsv_ext1 = xsb + 1;
                    dx_ext0 = dx0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dx_ext1 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                if ((c1 & 0x02) == 0) {
                    ysv_ext0 = ysb;
                    ysv_ext1 = ysb - 1;
                    dy_ext0 = dy0 - 3 * constants.SQUISH_CONSTANT4;
                    dy_ext1 = dy0 + 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                else {
                    ysv_ext0 = ysb + 1;
                    ysv_ext1 = ysb + 1;
                    dy_ext0 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dy_ext1 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                if ((c1 & 0x04) == 0) {
                    zsv_ext0 = zsb;
                    zsv_ext1 = zsb - 1;
                    dz_ext0 = dz0 - 3 * constants.SQUISH_CONSTANT4;
                    dz_ext1 = dz0 + 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                else {
                    zsv_ext0 = zsb + 1;
                    zsv_ext1 = zsb + 1;
                    dz_ext0 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dz_ext1 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                if ((c1 & 0x08) == 0) {
                    wsv_ext0 = wsb;
                    wsv_ext1 = wsb - 1;
                    dw_ext0 = dw0 - 3 * constants.SQUISH_CONSTANT4;
                    dw_ext1 = dw0 + 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                else {
                    wsv_ext0 = wsb + 1;
                    wsv_ext1 = wsb + 1;
                    dw_ext0 = dw0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dw_ext1 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                }
                //One combination is a _permutation of (0,0,0,2) based on c2
                xsv_ext2 = xsb;
                ysv_ext2 = ysb;
                zsv_ext2 = zsb;
                wsv_ext2 = wsb;
                dx_ext2 = dx0 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 2 * constants.SQUISH_CONSTANT4;
                if ((c2 & 0x01) != 0) {
                    xsv_ext2 += 2;
                    dx_ext2 -= 2;
                }
                else if ((c2 & 0x02) != 0) {
                    ysv_ext2 += 2;
                    dy_ext2 -= 2;
                }
                else if ((c2 & 0x04) != 0) {
                    zsv_ext2 += 2;
                    dz_ext2 -= 2;
                }
                else {
                    wsv_ext2 += 2;
                    dw_ext2 -= 2;
                }
            }
            else { //Both closest pos on the smaller side
                //One of the two extra pos is (0,0,0,0)
                xsv_ext2 = xsb;
                ysv_ext2 = ysb;
                zsv_ext2 = zsb;
                wsv_ext2 = wsb;
                dx_ext2 = dx0;
                dy_ext2 = dy0;
                dz_ext2 = dz0;
                dw_ext2 = dw0;
                //Other two pos are based on the omitted axes.
                c = a_po | b_po;
                if ((c & 0x01) == 0) {
                    xsv_ext0 = xsb - 1;
                    xsv_ext1 = xsb;
                    dx_ext0 = dx0 + 1 - constants.SQUISH_CONSTANT4;
                    dx_ext1 = dx0 - constants.SQUISH_CONSTANT4;
                }
                else {
                    xsv_ext0 = xsb + 1;
                    xsv_ext1 = xsb + 1;
                    dx_ext0 = dx0 - 1 - constants.SQUISH_CONSTANT4;
                    dx_ext1 = dx0 - 1 - constants.SQUISH_CONSTANT4;
                }
                if ((c & 0x02) == 0) {
                    ysv_ext0 = ysb;
                    ysv_ext1 = ysb;
                    dy_ext0 = dy0 - constants.SQUISH_CONSTANT4;
                    dy_ext1 = dy0 - constants.SQUISH_CONSTANT4;
                    if ((c & 0x01) == 0x01) {
                        ysv_ext0 -= 1;
                        dy_ext0 += 1;
                    }
                    else {
                        ysv_ext1 -= 1;
                        dy_ext1 += 1;
                    }
                }
                else {
                    ysv_ext0 = ysb + 1;
                    ysv_ext1 = ysb + 1;
                    dy_ext0 = dy0 - 1 - constants.SQUISH_CONSTANT4;
                    dy_ext1 = dy0 - 1 - constants.SQUISH_CONSTANT4;
                }
                if ((c & 0x04) == 0) {
                    zsv_ext0 = zsb;
                    zsv_ext1 = zsb;
                    dz_ext0 = dz0 - constants.SQUISH_CONSTANT4;
                    dz_ext1 = dz0 - constants.SQUISH_CONSTANT4;
                    if ((c & 0x03) == 0x03) {
                        zsv_ext0 -= 1;
                        dz_ext0 += 1;
                    }
                    else {
                        zsv_ext1 -= 1;
                        dz_ext1 += 1;
                    }
                }
                else {
                    zsv_ext0 = zsb + 1;
                    zsv_ext1 = zsb + 1;
                    dz_ext0 = dz0 - 1 - constants.SQUISH_CONSTANT4;
                    dz_ext1 = dz0 - 1 - constants.SQUISH_CONSTANT4;
                }
                if ((c & 0x08) == 0) {
                    wsv_ext0 = wsb;
                    wsv_ext1 = wsb - 1;
                    dw_ext0 = dw0 - constants.SQUISH_CONSTANT4;
                    dw_ext1 = dw0 + 1 - constants.SQUISH_CONSTANT4;
                }
                else {
                    wsv_ext0 = wsb + 1;
                    wsv_ext1 = wsb + 1;
                    dw_ext0 = dw0 - 1 - constants.SQUISH_CONSTANT4;
                    dw_ext1 = dw0 - 1 - constants.SQUISH_CONSTANT4;
                }
            }
        }
        else { //One po on each "side"
            if (a_is_bigger_side) {
                c1 = a_po;
                c2 = b_po;
            }
            else {
                c1 = b_po;
                c2 = a_po;
            }
            //Two contributions are the bigger-side po with each 0 replaced with -1
            if ((c1 & 0x01) == 0) {
                xsv_ext0 = xsb - 1;
                xsv_ext1 = xsb;
                dx_ext0 = dx0 + 1 - constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - constants.SQUISH_CONSTANT4;
            }
            else {
                xsv_ext0 = xsb + 1;
                xsv_ext1 = xsb + 1;
                dx_ext0 = dx0 - 1 - constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 1 - constants.SQUISH_CONSTANT4;
            }
            if ((c1 & 0x02) == 0) {
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                dy_ext0 = dy0 - constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - constants.SQUISH_CONSTANT4;
                if ((c1 & 0x01) == 0x01) {
                    ysv_ext0 -= 1;
                    dy_ext0 += 1;
                }
                else {
                    ysv_ext1 -= 1;
                    dy_ext1 += 1;
                }
            }
            else {
                ysv_ext0 = ysb + 1;
                ysv_ext1 = ysb + 1;
                dy_ext0 = dy0 - 1 - constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 1 - constants.SQUISH_CONSTANT4;
            }
            if ((c1 & 0x04) == 0) {
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                dz_ext0 = dz0 - constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - constants.SQUISH_CONSTANT4;
                if ((c1 & 0x03) == 0x03) {
                    zsv_ext0 -= 1;
                    dz_ext0 += 1;
                }
                else {
                    zsv_ext1 -= 1;
                    dz_ext1 += 1;
                }
            }
            else {
                zsv_ext0 = zsb + 1;
                zsv_ext1 = zsb + 1;
                dz_ext0 = dz0 - 1 - constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 1 - constants.SQUISH_CONSTANT4;
            }
            if ((c1 & 0x08) == 0) {
                wsv_ext0 = wsb;
                wsv_ext1 = wsb - 1;
                dw_ext0 = dw0 - constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 + 1 - constants.SQUISH_CONSTANT4;
            }
            else {
                wsv_ext0 = wsb + 1;
                wsv_ext1 = wsb + 1;
                dw_ext0 = dw0 - 1 - constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 1 - constants.SQUISH_CONSTANT4;
            }
            //One contribution is a _permutation of (0,0,0,2) based on the smaller-sided po
            xsv_ext2 = xsb;
            ysv_ext2 = ysb;
            zsv_ext2 = zsb;
            wsv_ext2 = wsb;
            dx_ext2 = dx0 - 2 * constants.SQUISH_CONSTANT4;
            dy_ext2 = dy0 - 2 * constants.SQUISH_CONSTANT4;
            dz_ext2 = dz0 - 2 * constants.SQUISH_CONSTANT4;
            dw_ext2 = dw0 - 2 * constants.SQUISH_CONSTANT4;
            if ((c2 & 0x01) != 0) {
                xsv_ext2 += 2;
                dx_ext2 -= 2;
            }
            else if ((c2 & 0x02) != 0) {
                ysv_ext2 += 2;
                dy_ext2 -= 2;
            }
            else if ((c2 & 0x04) != 0) {
                zsv_ext2 += 2;
                dz_ext2 -= 2;
            }
            else {
                wsv_ext2 += 2;
                dw_ext2 -= 2;
            }
        }
        //Contribution (1,0,0,0)
        dx1 = dx0 - 1 - constants.SQUISH_CONSTANT4;
        dy1 = dy0 - 0 - constants.SQUISH_CONSTANT4;
        dz1 = dz0 - 0 - constants.SQUISH_CONSTANT4;
        dw1 = dw0 - 0 - constants.SQUISH_CONSTANT4;
        attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
        if (attn1 > 0) {
            attn1 *= attn1;
            value += attn1 * attn1 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 0.0), (wsb + 0.0), dx1, dy1, dz1, dw1);
        }
        //Contribution (0,1,0,0)
        dx2 = dx0 - 0 - constants.SQUISH_CONSTANT4;
        dy2 = dy0 - 1 - constants.SQUISH_CONSTANT4;
        dz2 = dz1;
        dw2 = dw1;
        attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
        if (attn2 > 0) {
            attn2 *= attn2;
            value += attn2 * attn2 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 0.0), (wsb + 0.0), dx2, dy2, dz2, dw2);
        }
        //Contribution (0,0,1,0)
        dx3 = dx2;
        dy3 = dy1;
        dz3 = dz0 - 1 - constants.SQUISH_CONSTANT4;
        dw3 = dw1;
        attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
        if (attn3 > 0) {
            attn3 *= attn3;
            value += attn3 * attn3 * extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 1.0), (wsb + 0.0), dx3, dy3, dz3, dw3);
        }
        //Contribution (0,0,0,1)
        dx4 = dx2;
        dy4 = dy1;
        dz4 = dz1;
        dw4 = dw0 - 1 - constants.SQUISH_CONSTANT4;
        attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
        if (attn4 > 0) {
            attn4 *= attn4;
            value += attn4 * attn4 * extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 0.0), (wsb + 1.0), dx4, dy4, dz4, dw4);
        }
        //Contribution (1,1,0,0)
        dx5 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dy5 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dz5 = dz0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dw5 = dw0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5 - dw5 * dw5;
        if (attn5 > 0) {
            attn5 *= attn5;
            value += attn5 * attn5 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 0.0), (wsb + 0.0), dx5, dy5, dz5, dw5);
        }
        //Contribution (1,0,1,0)
        dx6 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dy6 = dy0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dz6 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dw6 = dw0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6 - dw6 * dw6;
        if (attn6 > 0) {
            attn6 *= attn6;
            value += attn6 * attn6 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 1.0), (wsb + 0.0), dx6, dy6, dz6, dw6);
        }
        //Contribution (1,0,0,1)
        dx7 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dy7 = dy0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dz7 = dz0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dw7 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        attn7 = 2 - dx7 * dx7 - dy7 * dy7 - dz7 * dz7 - dw7 * dw7;
        if (attn7 > 0) {
            attn7 *= attn7;
            value += attn7 * attn7 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 0.0), (wsb + 1.0), dx7, dy7, dz7, dw7);
        }
        //Contribution (0,1,1,0)
        dx8 = dx0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dy8 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dz8 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dw8 = dw0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        attn8 = 2 - dx8 * dx8 - dy8 * dy8 - dz8 * dz8 - dw8 * dw8;
        if (attn8 > 0) {
            attn8 *= attn8;
            value += attn8 * attn8 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 1.0), (wsb + 0.0), dx8, dy8, dz8, dw8);
        }
        //Contribution (0,1,0,1)
        dx9 = dx0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dy9 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dz9 = dz0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dw9 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        attn9 = 2 - dx9 * dx9 - dy9 * dy9 - dz9 * dz9 - dw9 * dw9;
        if (attn9 > 0) {
            attn9 *= attn9;
            value += attn9 * attn9 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 0.0), (wsb + 1.0), dx9, dy9, dz9, dw9);
        }
        //Contribution (0,0,1,1)
        dx10 = dx0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dy10 = dy0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dz10 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dw10 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        attn10 = 2 - dx10 * dx10 - dy10 * dy10 - dz10 * dz10 - dw10 * dw10;
        if (attn10 > 0) {
            attn10 *= attn10;
            value += attn10 * attn10 * extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 1.0), (wsb + 1.0), dx10, dy10, dz10, dw10);
        }
    }
    else { //We're inside the second dispentachoron (Rectified 4-Simplex)
        a_is_bigger_side = true;
        b_is_bigger_side = true;
        //Decide between (0,0,1,1) and (1,1,0,0)
        if ((xins + yins) < (zins + wins)) {
            a_score = xins + yins;
            a_po = 0x0C;
        }
        else {
            a_score = zins + wins;
            a_po = 0x03;
        }
        //Decide between (0,1,0,1) and (1,0,1,0)
        if ((xins + zins) < (yins + wins)) {
            b_score = xins + zins;
            b_po = 0x0A;
        }
        else {
            b_score = yins + wins;
            b_po = 0x05;
        }
        //Closer between (0,1,1,0) and (1,0,0,1) will replace the further of a and b, if closer.
        if ((xins + wins) < (yins + zins)) {
            score = xins + wins;
            if (a_score <= b_score && score < b_score) {
                b_score = score;
                b_po = 0x06;
            }
            else if (a_score > b_score && score < a_score) {
                a_score = score;
                a_po = 0x06;
            }
        }
        else {
            score = yins + zins;
            if (a_score <= b_score && score < b_score) {
                b_score = score;
                b_po = 0x09;
            }
            else if (a_score > b_score && score < a_score) {
                a_score = score;
                a_po = 0x09;
            }
        }
        //Decide if (0,1,1,1) is closer.
        p1 = 3 - in_sum + xins;
        if (a_score <= b_score && p1 < b_score) {
            b_score = p1;
            b_po = 0x0E;
            b_is_bigger_side = false;
        }
        else if (a_score > b_score && p1 < a_score) {
            a_score = p1;
            a_po = 0x0E;
            a_is_bigger_side = false;
        }
        //Decide if (1,0,1,1) is closer.
        p2 = 3 - in_sum + yins;
        if (a_score <= b_score && p2 < b_score) {
            b_score = p2;
            b_po = 0x0D;
            b_is_bigger_side = false;
        }
        else if (a_score > b_score && p2 < a_score) {
            a_score = p2;
            a_po = 0x0D;
            a_is_bigger_side = false;
        }
        //Decide if (1,1,0,1) is closer.
        p3 = 3 - in_sum + zins;
        if (a_score <= b_score && p3 < b_score) {
            b_score = p3;
            b_po = 0x0B;
            b_is_bigger_side = false;
        }
        else if (a_score > b_score && p3 < a_score) {
            a_score = p3;
            a_po = 0x0B;
            a_is_bigger_side = false;
        }
        //Decide if (1,1,1,0) is closer.
        p4 = 3 - in_sum + wins;
        if (a_score <= b_score && p4 < b_score) {
            b_po = 0x07;
            b_is_bigger_side = false;
        }
        else if (a_score > b_score && p4 < a_score) {
            a_po = 0x07;
            a_is_bigger_side = false;
        }
        //Where each of the two closest pos are determines how the extra three vertices are calculated.
        if (a_is_bigger_side == b_is_bigger_side) {
            if (a_is_bigger_side) {
                c1 = a_po & b_po;
                c2 = a_po | b_po;
                //Two contributions are _permutations of (0,0,0,1) and (0,0,0,2) based on c1
                xsv_ext0 = xsb;
                xsv_ext1 = xsb;
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                dx_ext0 = dx0 - constants.SQUISH_CONSTANT4;
                dy_ext0 = dy0 - constants.SQUISH_CONSTANT4;
                dz_ext0 = dz0 - constants.SQUISH_CONSTANT4;
                dw_ext0 = dw0 - constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 2 * constants.SQUISH_CONSTANT4;
                if ((c1 & 0x01) != 0) {
                    xsv_ext0 += 1;
                    dx_ext0 -= 1;
                    xsv_ext1 += 2;
                    dx_ext1 -= 2;
                }
                else if ((c1 & 0x02) != 0) {
                    ysv_ext0 += 1;
                    dy_ext0 -= 1;
                    ysv_ext1 += 2;
                    dy_ext1 -= 2;
                }
                else if ((c1 & 0x04) != 0) {
                    zsv_ext0 += 1;
                    dz_ext0 -= 1;
                    zsv_ext1 += 2;
                    dz_ext1 -= 2;
                }
                else {
                    wsv_ext0 += 1;
                    dw_ext0 -= 1;
                    wsv_ext1 += 2;
                    dw_ext1 -= 2;
                }
                //One contribution is a _permutation of (1,1,1,-1) based on c2
                xsv_ext2 = xsb + 1;
                ysv_ext2 = ysb + 1;
                zsv_ext2 = zsb + 1;
                wsv_ext2 = wsb + 1;
                dx_ext2 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
                if ((c2 & 0x01) == 0) {
                    xsv_ext2 -= 2;
                    dx_ext2 += 2;
                }
                else if ((c2 & 0x02) == 0) {
                    ysv_ext2 -= 2;
                    dy_ext2 += 2;
                }
                else if ((c2 & 0x04) == 0) {
                    zsv_ext2 -= 2;
                    dz_ext2 += 2;
                }
                else {
                    wsv_ext2 -= 2;
                    dw_ext2 += 2;
                }
            }
            else { //Both closest pos on the smaller side
                xsv_ext0 = xsb;
                xsv_ext1 = xsb;
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                dx_ext0 = dx0 - constants.SQUISH_CONSTANT4;
                dy_ext0 = dy0 - constants.SQUISH_CONSTANT4;
                dz_ext0 = dz0 - constants.SQUISH_CONSTANT4;
                dw_ext0 = dw0 - constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 2 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 2 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 2 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 2 * constants.SQUISH_CONSTANT4;
                //One of the two extra pos is (1,1,1,1)
                xsv_ext2 = xsb + 1;
                ysv_ext2 = ysb + 1;
                zsv_ext2 = zsb + 1;
                wsv_ext2 = wsb + 1;
                dx_ext2 = dx0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dy_ext2 = dy0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dz_ext2 = dz0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                dw_ext2 = dw0 - 1 - 4 * constants.SQUISH_CONSTANT4;
                //Other two pos are based on the shared axes.
                c = a_po & b_po;
                if ((c & 0x01) != 0) {
                    xsv_ext0 = xsb + 2;
                    xsv_ext1 = xsb + 1;
                    dx_ext0 = dx0 - 2 - 3 * constants.SQUISH_CONSTANT4;
                    dx_ext1 = dx0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                }
                else {
                    xsv_ext0 = xsb;
                    xsv_ext1 = xsb;
                    dx_ext0 = dx0 - 3 * constants.SQUISH_CONSTANT4;
                    dx_ext1 = dx0 - 3 * constants.SQUISH_CONSTANT4;
                }
                if ((c & 0x02) != 0) {
                    ysv_ext0 = ysb + 1;
                    ysv_ext1 = ysb + 1;
                    dy_ext0 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dy_ext1 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    if ((c & 0x01) == 0) {
                        ysv_ext0 += 1;
                        dy_ext0 -= 1;
                    }
                    else {
                        ysv_ext1 += 1;
                        dy_ext1 -= 1;
                    }
                }
                else {
                    ysv_ext0 = ysb;
                    ysv_ext1 = ysb;
                    dy_ext0 = dy0 - 3 * constants.SQUISH_CONSTANT4;
                    dy_ext1 = dy0 - 3 * constants.SQUISH_CONSTANT4;
                }
                if ((c & 0x04) != 0) {
                    zsv_ext0 = zsb + 1;
                    zsv_ext1 = zsb + 1;
                    dz_ext0 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dz_ext1 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    if ((c & 0x03) == 0) {
                        zsv_ext0 += 1;
                        dz_ext0 -= 1;
                    }
                    else {
                        zsv_ext1 += 1;
                        dz_ext1 -= 1;
                    }
                }
                else {
                    zsv_ext0 = zsb;
                    zsv_ext1 = zsb;
                    dz_ext0 = dz0 - 3 * constants.SQUISH_CONSTANT4;
                    dz_ext1 = dz0 - 3 * constants.SQUISH_CONSTANT4;
                }
                if ((c & 0x08) != 0) {
                    wsv_ext0 = wsb + 1;
                    wsv_ext1 = wsb + 2;
                    dw_ext0 = dw0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                    dw_ext1 = dw0 - 2 - 3 * constants.SQUISH_CONSTANT4;
                }
                else {
                    wsv_ext0 = wsb;
                    wsv_ext1 = wsb;
                    dw_ext0 = dw0 - 3 * constants.SQUISH_CONSTANT4;
                    dw_ext1 = dw0 - 3 * constants.SQUISH_CONSTANT4;
                }
            }
        }
        else { //One po on each "side"
            if (a_is_bigger_side) {
                c1 = a_po;
                c2 = b_po;
            }
            else {
                c1 = b_po;
                c2 = a_po;
            }
            //Two contributions are the bigger-sided po with each 1 replaced with 2
            if ((c1 & 0x01) != 0) {
                xsv_ext0 = xsb + 2;
                xsv_ext1 = xsb + 1;
                dx_ext0 = dx0 - 2 - 3 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 1 - 3 * constants.SQUISH_CONSTANT4;
            }
            else {
                xsv_ext0 = xsb;
                xsv_ext1 = xsb;
                dx_ext0 = dx0 - 3 * constants.SQUISH_CONSTANT4;
                dx_ext1 = dx0 - 3 * constants.SQUISH_CONSTANT4;
            }
            if ((c1 & 0x02) != 0) {
                ysv_ext0 = ysb + 1;
                ysv_ext1 = ysb + 1;
                dy_ext0 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                if ((c1 & 0x01) == 0) {
                    ysv_ext0 += 1;
                    dy_ext0 -= 1;
                }
                else {
                    ysv_ext1 += 1;
                    dy_ext1 -= 1;
                }
            }
            else {
                ysv_ext0 = ysb;
                ysv_ext1 = ysb;
                dy_ext0 = dy0 - 3 * constants.SQUISH_CONSTANT4;
                dy_ext1 = dy0 - 3 * constants.SQUISH_CONSTANT4;
            }
            if ((c1 & 0x04) != 0) {
                zsv_ext0 = zsb + 1;
                zsv_ext1 = zsb + 1;
                dz_ext0 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                if ((c1 & 0x03) == 0) {
                    zsv_ext0 += 1;
                    dz_ext0 -= 1;
                }
                else {
                    zsv_ext1 += 1;
                    dz_ext1 -= 1;
                }
            }
            else {
                zsv_ext0 = zsb;
                zsv_ext1 = zsb;
                dz_ext0 = dz0 - 3 * constants.SQUISH_CONSTANT4;
                dz_ext1 = dz0 - 3 * constants.SQUISH_CONSTANT4;
            }
            if ((c1 & 0x08) != 0) {
                wsv_ext0 = wsb + 1;
                wsv_ext1 = wsb + 2;
                dw_ext0 = dw0 - 1 - 3 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 2 - 3 * constants.SQUISH_CONSTANT4;
            }
            else {
                wsv_ext0 = wsb;
                wsv_ext1 = wsb;
                dw_ext0 = dw0 - 3 * constants.SQUISH_CONSTANT4;
                dw_ext1 = dw0 - 3 * constants.SQUISH_CONSTANT4;
            }
            //One contribution is a _permutation of (1,1,1,-1) based on the smaller-sided po
            xsv_ext2 = xsb + 1;
            ysv_ext2 = ysb + 1;
            zsv_ext2 = zsb + 1;
            wsv_ext2 = wsb + 1;
            dx_ext2 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
            dy_ext2 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
            dz_ext2 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
            dw_ext2 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
            if ((c2 & 0x01) == 0) {
                xsv_ext2 -= 2;
                dx_ext2 += 2;
            }
            else if ((c2 & 0x02) == 0) {
                ysv_ext2 -= 2;
                dy_ext2 += 2;
            }
            else if ((c2 & 0x04) == 0) {
                zsv_ext2 -= 2;
                dz_ext2 += 2;
            }
            else {
                wsv_ext2 -= 2;
                dw_ext2 += 2;
            }
        }
        //Contribution (1,1,1,0)
        dx4 = dx0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        dy4 = dy0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        dz4 = dz0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        dw4 = dw0 - 3 * constants.SQUISH_CONSTANT4;
        attn4 = 2 - dx4 * dx4 - dy4 * dy4 - dz4 * dz4 - dw4 * dw4;
        if (attn4 > 0) {
            attn4 *= attn4;
            value += attn4 * attn4 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 1.0), (wsb + 0.0), dx4, dy4, dz4, dw4);
        }
        //Contribution (1,1,0,1)
        dx3 = dx4;
        dy3 = dy4;
        dz3 = dz0 - 3 * constants.SQUISH_CONSTANT4;
        dw3 = dw0 - 1 - 3 * constants.SQUISH_CONSTANT4;
        attn3 = 2 - dx3 * dx3 - dy3 * dy3 - dz3 * dz3 - dw3 * dw3;
        if (attn3 > 0) {
            attn3 *= attn3;
            value += attn3 * attn3 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 0.0), (wsb + 1.0), dx3, dy3, dz3, dw3);
        }
        //Contribution (1,0,1,1)
        dx2 = dx4;
        dy2 = dy0 - 3 * constants.SQUISH_CONSTANT4;
        dz2 = dz4;
        dw2 = dw3;
        attn2 = 2 - dx2 * dx2 - dy2 * dy2 - dz2 * dz2 - dw2 * dw2;
        if (attn2 > 0) {
            attn2 *= attn2;
            value += attn2 * attn2 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 1.0), (wsb + 1.0), dx2, dy2, dz2, dw2);
        }
        //Contribution (0,1,1,1)
        dx1 = dx0 - 3 * constants.SQUISH_CONSTANT4;
        dz1 = dz4;
        dy1 = dy4;
        dw1 = dw3;
        attn1 = 2 - dx1 * dx1 - dy1 * dy1 - dz1 * dz1 - dw1 * dw1;
        if (attn1 > 0) {
            attn1 *= attn1;
            value += attn1 * attn1 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 1.0), (wsb + 1.0), dx1, dy1, dz1, dw1);
        }
        //Contribution (1,1,0,0)
        dx5 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dy5 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dz5 = dz0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dw5 = dw0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        attn5 = 2 - dx5 * dx5 - dy5 * dy5 - dz5 * dz5 - dw5 * dw5;
        if (attn5 > 0) {
            attn5 *= attn5;
            value += attn5 * attn5 * extrapolate4((xsb + 1.0), (ysb + 1.0), (zsb + 0.0), (wsb + 0.0), dx5, dy5, dz5, dw5);
        }
        //Contribution (1,0,1,0)
        dx6 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dy6 = dy0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dz6 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dw6 = dw0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        attn6 = 2 - dx6 * dx6 - dy6 * dy6 - dz6 * dz6 - dw6 * dw6;
        if (attn6 > 0) {
            attn6 *= attn6;
            value += attn6 * attn6 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 1.0), (wsb + 0.0), dx6, dy6, dz6, dw6);
        }
        //Contribution (1,0,0,1)
        dx7 = dx0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dy7 = dy0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dz7 = dz0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dw7 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        attn7 = 2 - dx7 * dx7 - dy7 * dy7 - dz7 * dz7 - dw7 * dw7;
        if (attn7 > 0) {
            attn7 *= attn7;
            value += attn7 * attn7 * extrapolate4((xsb + 1.0), (ysb + 0.0), (zsb + 0.0), (wsb + 1.0), dx7, dy7, dz7, dw7);
        }
        //Contribution (0,1,1,0)
        dx8 = dx0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dy8 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dz8 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dw8 = dw0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        attn8 = 2 - dx8 * dx8 - dy8 * dy8 - dz8 * dz8 - dw8 * dw8;
        if (attn8 > 0) {
            attn8 *= attn8;
            value += attn8 * attn8 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 1.0), (wsb + 0.0), dx8, dy8, dz8, dw8);
        }
        //Contribution (0,1,0,1)
        dx9 = dx0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dy9 = dy0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dz9 = dz0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dw9 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        attn9 = 2 - dx9 * dx9 - dy9 * dy9 - dz9 * dz9 - dw9 * dw9;
        if (attn9 > 0) {
            attn9 *= attn9;
            value += attn9 * attn9 * extrapolate4((xsb + 0.0), (ysb + 1.0), (zsb + 0.0), (wsb + 1.0), dx9, dy9, dz9, dw9);
        }
        //Contribution (0,0,1,1)
        dx10 = dx0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dy10 = dy0 - 0 - 2 * constants.SQUISH_CONSTANT4;
        dz10 = dz0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        dw10 = dw0 - 1 - 2 * constants.SQUISH_CONSTANT4;
        attn10 = 2 - dx10 * dx10 - dy10 * dy10 - dz10 * dz10 - dw10 * dw10;
        if (attn10 > 0) {
            attn10 *= attn10;
            value += attn10 * attn10 * extrapolate4((xsb + 0.0), (ysb + 0.0), (zsb + 1.0), (wsb + 1.0), dx10, dy10, dz10, dw10);
        }
    }
    //First extra vertex
    attn_ext0 = 2 - dx_ext0 * dx_ext0 - dy_ext0 * dy_ext0 - dz_ext0 * dz_ext0 - dw_ext0 * dw_ext0;
    if (attn_ext0 > 0) {
        attn_ext0 *= attn_ext0;
        value += (
            attn_ext0
            * attn_ext0
            * extrapolate4(xsv_ext0, ysv_ext0, zsv_ext0, wsv_ext0, dx_ext0, dy_ext0, dz_ext0, dw_ext0)
                  );
    }
    //Second extra vertex
    attn_ext1 = 2 - dx_ext1 * dx_ext1 - dy_ext1 * dy_ext1 - dz_ext1 * dz_ext1 - dw_ext1 * dw_ext1;
    if (attn_ext1 > 0) {
        attn_ext1 *= attn_ext1;
        value += (
            attn_ext1
            * attn_ext1
            * extrapolate4(xsv_ext1, ysv_ext1, zsv_ext1, wsv_ext1, dx_ext1, dy_ext1, dz_ext1, dw_ext1)
                  );
    }
    //Third extra vertex
    attn_ext2 = 2 - dx_ext2 * dx_ext2 - dy_ext2 * dy_ext2 - dz_ext2 * dz_ext2 - dw_ext2 * dw_ext2;
    if (attn_ext2 > 0) {
        attn_ext2 *= attn_ext2;
        value += (
            attn_ext2
            * attn_ext2
            * extrapolate4(xsv_ext2, ysv_ext2, zsv_ext2, wsv_ext2, dx_ext2, dy_ext2, dz_ext2, dw_ext2)
                  );
    }
    float result = (value / int_constants.NORM_CONSTANT4);
    return result;
}

float noise_function(float x, float y, float z, float w) {
    float total = 0.0;
    float amplitude = 1.0;
    float max_amplitude = 0.0;
    float _period = int_constants.period;
    for (int i = 0; i < int_constants.octaves; i++) {
        total += (single_noise4((x * _period), (y * _period), (z * _period), (w * _period)) * amplitude);
        max_amplitude += amplitude;
        amplitude *= constants.persistence;
        _period *= constants.lacunarity;
    }
    float result = max_amplitude != 0.0 ? total / max_amplitude : 0.0;
    return result;
}

//Main function
void main() {
    uint index = gl_GlobalInvocationID.x;
    ivec2 angle = input_buffer.inputs[index];
    float scale_factor = TAU / 10000;
    float angle_x = scale_factor * angle.x;
    float angle_y = scale_factor * angle.y;
    float x = cos(angle_x);
    float y = sin(angle_x);
    float z = cos(angle_y);
    float w = sin(angle_y);
    output_buffer.outputs[index] = noise_function(x, y, z, w);
}
