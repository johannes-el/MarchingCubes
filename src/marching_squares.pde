int cols, rows;
float[][] field;
int resolution = 20;
float threshold = 0.5;

int probeX = 0;
int probeY = 0;

ArrayList<LineSegment> segments;
boolean done = false;

void setup() {
  size(600, 600, P2D);
  cols = width / resolution + 1;
  rows = height / resolution + 1;
  field = new float[cols][rows];
  segments = new ArrayList<LineSegment>();

  float xoff = 0;
  for (int i = 0; i < cols; i++) {
    float yoff = 0;
    for (int j = 0; j < rows; j++) {
      field[i][j] = noise(xoff, yoff);
      yoff += 0.1;
    }
    xoff += 0.1;
  }

  frameRate(15);
}

void draw() {
  background(255);

  noStroke();
  for (int x = 0; x < cols - 1; x++) {
    for (int y = 0; y < rows - 1; y++) {
      float a = field[x][y];
      float b = field[x+1][y];
      float c = field[x+1][y+1];
      float d = field[x][y+1];

      float x0 = x * resolution;
      float y0 = y * resolution;
      float x1 = (x + 1) * resolution;
      float y1 = (y + 1) * resolution;

      beginShape(TRIANGLES);
      fill(a * 255); vertex(x0, y0);
      fill(b * 255); vertex(x1, y0);
      fill(c * 255); vertex(x1, y1);
      endShape();

      beginShape(TRIANGLES);
      fill(a * 255); vertex(x0, y0);
      fill(c * 255); vertex(x1, y1);
      fill(d * 255); vertex(x0, y1);
      endShape();
    }
  }

  stroke(0);
  strokeWeight(2);
  for (LineSegment seg : segments) {
    line(seg.a.x, seg.a.y, seg.b.x, seg.b.y);
  }

  if (!done) {
  int speed = 4;
  for (int i = 0; i < speed; i++) {
    drawMarchingSquare(probeX, probeY);

    probeX++;
    if (probeX >= cols - 1) {
      probeX = 0;
      probeY++;
      if (probeY >= rows - 1) {
        done = true;
        break;
      }
    }
  }

  // Draw the rectangle on the **previous** probe cell
  int drawX = probeX - 1;
  int drawY = probeY;
  if (drawX < 0) {
    drawX = cols - 2;
    drawY = probeY - 1;
  }

  stroke(0, 150, 255);
  strokeWeight(2);
  noFill();
  rect(drawX * resolution, drawY * resolution, resolution, resolution);
}

}

void drawMarchingSquare(int x, int y) {
  float x1 = x * resolution;
  float y1 = y * resolution;

  float a = field[x][y];
  float b = field[x+1][y];
  float c = field[x+1][y+1];
  float d = field[x][y+1];

  int state = 0;
  if (a > threshold) state |= 1;
  if (b > threshold) state |= 2;
  if (c > threshold) state |= 4;
  if (d > threshold) state |= 8;

  float half = resolution / 2.0;
  PVector[] points = new PVector[4];
  points[0] = new PVector(x1 + half, y1);               // top
  points[1] = new PVector(x1 + resolution, y1 + half);  // right
  points[2] = new PVector(x1 + half, y1 + resolution);  // bottom
  points[3] = new PVector(x1, y1 + half);               // left

  switch(state) {
    case 1: case 14: segments.add(new LineSegment(points[3], points[0])); break;
    case 2: case 13: segments.add(new LineSegment(points[0], points[1])); break;
    case 3: case 12: segments.add(new LineSegment(points[3], points[1])); break;
    case 4: case 11: segments.add(new LineSegment(points[1], points[2])); break;
    case 5:
      segments.add(new LineSegment(points[3], points[0]));
      segments.add(new LineSegment(points[1], points[2]));
      break;
    case 6: case 9: segments.add(new LineSegment(points[0], points[2])); break;
    case 7: case 8: segments.add(new LineSegment(points[3], points[2])); break;
    case 10:
      segments.add(new LineSegment(points[0], points[1]));
      segments.add(new LineSegment(points[2], points[3]));
      break;
    default: break;
  }
}

class LineSegment {
  PVector a, b;
  LineSegment(PVector a, PVector b) {
    this.a = a.copy();
    this.b = b.copy();
  }
}
