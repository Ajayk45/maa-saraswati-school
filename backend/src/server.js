const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const multer = require('multer');
const path = require('path');
require('dotenv').config();

const db = require('./db');
const { admin } = require('./auth');

const app = express();
const port = Number(process.env.PORT || 5000);

app.use(cors());
app.use(express.json({ limit: '2mb' }));

const uploadsRoot = path.join(__dirname, 'uploads');
const galleryUploadsDir = path.join(uploadsRoot, 'gallery');
fs.mkdirSync(galleryUploadsDir, { recursive: true });
app.use('/uploads', express.static(uploadsRoot));

 const galleryStorage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, galleryUploadsDir),

  filename: (_, file, cb) => {
    const ext = path.extname(file.originalname || '').toLowerCase();

    const safeExt = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
    ].includes(ext)
      ? ext
      : '.jpg';

    cb(
      null,
      `gallery_${Date.now()}_${Math.random()
        .toString(36)
        .slice(2, 8)}${safeExt}`
    );
  },
});

const allowedExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
  '.gif',
];

const allowedMimeTypes = [
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/gif',
  'application/octet-stream',
];

const uploadGalleryImage = multer({
  storage: galleryStorage,

  limits: {
    fileSize: 10 * 1024 * 1024,
  },

  fileFilter: (req, file, cb) => {
    const extension = path
      .extname(file.originalname || '')
      .toLowerCase();

    const mimeType = String(
      file.mimetype || ''
    ).toLowerCase();

    if (
      allowedExtensions.includes(extension) &&
      allowedMimeTypes.includes(mimeType)
    ) {
      return cb(null, true);
    }

    // Flutter Web may send valid images as application/octet-stream.
    if (allowedExtensions.includes(extension)) {
      return cb(null, true);
    }

    return cb(
      new Error(
        'Only JPG, JPEG, PNG, WEBP and GIF image files are allowed.'
      )
    );
  },
}).single('image');

function publicImageUrl(req, imageUrl) {
  const value = String(imageUrl || '');
  if (!value) return '';
  if (/^https?:\/\//i.test(value)) return value;
  return `${req.protocol}://${req.get('host')}${value.startsWith('/') ? value : `/${value}`}`;
}


// ==========================================================
// HEALTH
// ==========================================================

app.get('/api/health', async (_, res) => {
  try {
    const info = await db.testConnection();

    res.json({
      ok: true,
      message: 'School CMS API is running',
      database: info.current_database,
      user: info.current_user,
    });
  } catch (error) {
    console.error('Health/database error:', error);

    res.status(500).json({
      ok: false,
      error: 'Database connection failed',
      details: error.message,
    });
  }
});

// ==========================================================
// ADMIN LOGIN
// ==========================================================

app.post('/api/admin/login', async (req, res) => {
  try {
    const username = String(
      req.body?.username || ''
    ).trim();

    const password = String(
      req.body?.password || ''
    );

    if (!username || !password) {
      return res.status(400).json({
        error: 'Username and password are required',
      });
    }

    const result = await db.query(
      'SELECT * FROM admin_users WHERE username = $1',
      [username],
    );

    const user = result.rows[0];

    if (
      !user ||
      !(await bcrypt.compare(
        password,
        user.password_hash,
      ))
    ) {
      return res.status(401).json({
        error: 'Invalid credentials',
      });
    }

    const secret = process.env.JWT_SECRET;

    if (
      !secret ||
      secret === 'replace-with-a-long-random-secret'
    ) {
      return res.status(500).json({
        error: 'JWT_SECRET is not configured correctly',
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
      },
      secret,
      {
        expiresIn: '8h',
      },
    );

    res.json({
      message: 'Login successful',
      token,
    });
  } catch (error) {
    console.error('Admin login error:', error);

    res.status(500).json({
      error: 'Login failed',
      details: error.message,
    });
  }
});

// ==========================================================
// CONTENT
// ==========================================================

function mapContent(result) {
  const x = result.rows[0];

  if (!x) {
    return {
      heroTitle: '',
      heroText: '',
      aboutTitle: '',
      aboutText: '',
      academicsTitle: '',
      academicsText: '',
      studentLifeTitle: '',
      studentLifeText: '',
      rulesTitle: '',
      rulesText: '',
      events: [],
    };
  }

  return {
    heroTitle: x.hero_title,
    heroText: x.hero_text,

    aboutTitle: x.about_title,
    aboutText: x.about_text,

    academicsTitle: x.academics_title,
    academicsText: x.academics_text,

    studentLifeTitle: x.student_life_title,
    studentLifeText: x.student_life_text,

    rulesTitle: x.rules_title,
    rulesText: x.rules_text,

    events: [],
  };
}

// PUBLIC CONTENT

app.get('/api/content', async (_, res) => {
  try {
    const contentResult = await db.query(
      'SELECT * FROM site_content WHERE id = 1',
    );

    const eventsResult = await db.query(`
      SELECT
        id,
        title,
        event_date,
        description
      FROM events
      WHERE event_date >= CURRENT_DATE
      ORDER BY event_date ASC
    `);

    const content = mapContent(
      contentResult,
    );

    content.events = eventsResult.rows.map(
      (event) => ({
        id: event.id,
        title: event.title,
        date: event.event_date,
        description:
          event.description || '',
      }),
    );

    res.json(content);
  } catch (error) {
    console.error(
      'Content error:',
      error,
    );

    res.status(500).json({
      error: 'Unable to load content',
      details: error.message,
    });
  }
});

// ADMIN GET CONTENT

app.get(
  '/api/admin/content',
  admin,
  async (_, res) => {
    try {
      const result = await db.query(
        'SELECT * FROM site_content WHERE id = 1',
      );

      res.json(
        mapContent(result),
      );
    } catch (error) {
      console.error(
        'Admin content error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to load CMS',
        details: error.message,
      });
    }
  },
);

// ADMIN SAVE CONTENT

app.put(
  '/api/admin/content',
  admin,
  async (req, res) => {
    try {
      const data = req.body || {};

      await db.query(
        `UPDATE site_content SET
          hero_title=$1,
          hero_text=$2,
          about_title=$3,
          about_text=$4,
          academics_title=$5,
          academics_text=$6,
          student_life_title=$7,
          student_life_text=$8,
          rules_title=$9,
          rules_text=$10,
          updated_at=NOW()
         WHERE id=1`,
        [
          data.heroTitle,
          data.heroText,

          data.aboutTitle,
          data.aboutText,

          data.academicsTitle,
          data.academicsText,

          data.studentLifeTitle,
          data.studentLifeText,

          data.rulesTitle,
          data.rulesText,
        ],
      );

      res.json({
        ok: true,
        message:
          'Content saved successfully',
      });
    } catch (error) {
      console.error(
        'Save content error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to save content',
        details: error.message,
      });
    }
  },
);

// ==========================================================
// INQUIRIES
// ==========================================================

app.post(
  '/api/inquiries',
  async (req, res) => {
    try {
      const data = req.body || {};

      const parentName = String(
        data.parentName || '',
      ).trim();

      const mobile = String(
        data.mobile || '',
      ).trim();

      const studentName = String(
        data.studentName || '',
      ).trim();

      const email = String(
        data.email || '',
      ).trim();

      const className = String(
        data.className || '',
      ).trim();

      const message = String(
        data.message || '',
      ).trim();

      if (
        !parentName ||
        !mobile ||
        !email ||
        !studentName ||
        !className
      ) {
        return res.status(400).json({
          error:
            'Parent name, mobile, email, student name and class are required',
        });
      }

      if (!/^[0-9]{10}$/.test(mobile)) {
        return res.status(400).json({
          error:
            'Mobile number exactly 10 digits ka hona chahiye.',
        });
      }

      const result = await db.query(
        `INSERT INTO inquiries
        (
          parent_name,
          mobile,
          student_name,
          email,
          class_name,
          message
        )
        VALUES ($1,$2,$3,$4,$5,$6)
        RETURNING *`,
        [
          parentName,
          mobile,
          studentName,
          email,
          className,
          message,
        ],
      );

      res.status(201).json({
        message: 'Inquiry successfully create ho gaya.',
        inquiry: result.rows[0],
      });
    } catch (error) {
      console.error(
        'Create inquiry error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to submit enquiry',
        details: error.message,
      });
    }
  },
);

// ADMIN INQUIRIES

app.get(
  '/api/admin/inquiries',
  admin,
  async (_, res) => {
    try {
      const result = await db.query(
        `SELECT *
         FROM inquiries
         ORDER BY created_at DESC`,
      );

      res.json(result.rows);
    } catch (error) {
      console.error(
        'Get inquiries error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to load inquiries',
        details: error.message,
      });
    }
  },
);
// ADMIN - DELETE INQUIRY

app.delete(
  '/api/admin/inquiries/:id',
  admin,
  async (req, res) => {
    try {
      const result = await db.query(
        `
        DELETE FROM inquiries
        WHERE id=$1
        RETURNING id
        `,
        [req.params.id],
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          error: 'Inquiry not found.',
        });
      }

      res.json({
        ok: true,
        message: 'Inquiry deleted successfully.',
      });
    } catch (error) {
      console.error(
        'Delete inquiry error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to delete inquiry',
        details: error.message,
      });
    }
  },
);
// ==========================================================
// CONTACT
// ==========================================================

app.post(
  '/api/contact',
  async (req, res) => {
    try {
      const data = req.body || {};

      if (
        !data.name ||
        !data.mobile ||
        !data.message
      ) {
        return res.status(400).json({
          error:
            'Name, mobile and message are required',
        });
      }

      const result = await db.query(
        `INSERT INTO contact_messages
          (
            name,
            mobile,
            email,
            message
          )
         VALUES ($1,$2,$3,$4)
         RETURNING id, created_at`,
        [
          String(
            data.name,
          ).trim(),

          String(
            data.mobile,
          ).trim(),

          data.email
            ? String(
                data.email,
              ).trim()
            : null,

          String(
            data.message,
          ).trim(),
        ],
      );

      res.status(201).json(
        result.rows[0],
      );
    } catch (error) {
      console.error(
        'Contact error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to send message',
        details: error.message,
      });
    }
  },
);

// ADMIN CONTACT

app.get(
  '/api/admin/contact',
  admin,
  async (_, res) => {
    try {
      const result = await db.query(
        `SELECT *
         FROM contact_messages
         ORDER BY created_at DESC`,
      );

      res.json(result.rows);
    } catch (error) {
      console.error(
        'Get contact error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to load contact messages',
        details: error.message,
      });
    }
  },
);

// ADMIN - MARK CONTACT MESSAGE AS READ

app.patch(
  '/api/admin/contact/:id/read',
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          error: 'Invalid message ID.',
        });
      }

      const result = await db.query(
        `UPDATE contact_messages
         SET is_read = TRUE
         WHERE id = $1
         RETURNING id, is_read`,
        [id],
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          error: 'Contact message not found.',
        });
      }

      res.json({
        ok: true,
        message: 'Message marked as read.',
        data: result.rows[0],
      });
    } catch (error) {
      console.error(
        'Mark contact message read error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to mark message as read',
        details: error.message,
      });
    }
  },
);
// ADMIN - DELETE CONTACT MESSAGE
 
app.delete(
  '/api/admin/contact/:id',
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          error: 'Invalid message ID.',
        });
      }

      const result = await db.query(
        `DELETE FROM contact_messages
         WHERE id = $1
         RETURNING id`,
        [id],
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          error: 'Contact message not found.',
        });
      }

      res.json({
        ok: true,
        message: 'Contact message deleted successfully.',
      });
    } catch (error) {
      console.error(
        'Delete contact message error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to delete contact message',
        details: error.message,
      });
    }
  },
);
// ==========================================================
// EVENTS
// ==========================================================

app.post(
  '/api/admin/events',
  admin,
  async (req, res) => {
    try {
      const data = req.body || {};

      if (
        !data.title ||
        !data.date
      ) {
        return res.status(400).json({
          error:
            'Event title and date are required',
        });
      }

      const result = await db.query(
        `INSERT INTO events
          (
            title,
            event_date,
            description
          )
         VALUES ($1,$2,$3)
         RETURNING *`,
        [
          String(
            data.title,
          ).trim(),

          data.date,

          String(
            data.description || '',
          ).trim(),
        ],
      );

      res.status(201).json(
        result.rows[0],
      );
    } catch (error) {
      console.error(
        'Create event error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to create event',
        details: error.message,
      });
    }
  },
);

app.delete(
  '/api/admin/events/:id',
  admin,
  async (req, res) => {
    try {
      await db.query(
        'DELETE FROM events WHERE id=$1',
        [req.params.id],
      );

      res.json({
        ok: true,
        message: 'Event deleted',
      });
    } catch (error) {
      console.error(
        'Delete event error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to delete event',
        details: error.message,
      });
    }
  },
);

// ==========================================================
// GALLERY
// ==========================================================

// PUBLIC - GET GALLERY

app.get(
  '/api/gallery',
  async (req, res) => {
    try {
      const result = await db.query(`
        SELECT
          id,
          title,
          description,
          image_url,
          created_at
        FROM gallery
        ORDER BY created_at DESC
      `);

      res.json(
        result.rows.map((item) => ({
          ...item,
          image_url: publicImageUrl(req, item.image_url),
        })),
      );
    } catch (error) {
      console.error(
        'Get gallery error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to load gallery',
        details: error.message,
      });
    }
  },
);

// ADMIN - UPLOAD GALLERY IMAGE + CREATE POST

app.post(
  '/api/admin/gallery/upload',
  admin,
  (req, res) => {
    uploadGalleryImage(req, res, async (uploadError) => {
      try {
        if (uploadError) {
          return res.status(400).json({
            error: uploadError.message || 'Image upload failed.',
          });
        }

        const title = String(req.body?.title || '').trim();
        const description = String(req.body?.description || '').trim();

        if (!title) {
          if (req.file) fs.unlink(req.file.path, () => {});
          return res.status(400).json({ error: 'Gallery title required.' });
        }

        if (!req.file) {
          return res.status(400).json({ error: 'Image file required.' });
        }

        const imageUrl = `/uploads/gallery/${req.file.filename}`;

        const result = await db.query(
          `INSERT INTO gallery (title, description, image_url)
           VALUES ($1,$2,$3)
           RETURNING *`,
          [title, description, imageUrl],
        );

        return res.status(201).json({
          message: 'Gallery photo uploaded successfully.',
          gallery: {
            ...result.rows[0],
            image_url: publicImageUrl(req, result.rows[0].image_url),
          },
        });
      } catch (error) {
        if (req.file) fs.unlink(req.file.path, () => {});
        console.error('CREATE GALLERY UPLOAD ERROR:', error);
        return res.status(500).json({
          error: 'Unable to upload gallery photo',
          details: error.message,
        });
      }
    });
  },
);
// --------------------------------------------------------
// FACULTY / PRINCIPAL PHOTO UPLOAD
// --------------------------------------------------------

const facultyUploadsDir = path.join(
  uploadsRoot,
  'faculty',
);

fs.mkdirSync(facultyUploadsDir, {
  recursive: true,
});

const facultyStorage = multer.diskStorage({
  destination: (_, __, cb) => {
    cb(null, facultyUploadsDir);
  },

  filename: (_, file, cb) => {
    const ext =
      path.extname(
        file.originalname || '',
      ).toLowerCase() || '.jpg';

    const safeExt = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
    ].includes(ext)
      ? ext
      : '.jpg';

    cb(
      null,
      `faculty_${Date.now()}_${Math.random()
        .toString(36)
        .slice(2, 8)}${safeExt}`,
    );
  },
});

const uploadFacultyImage = multer({
  storage: facultyStorage,

  limits: {
    fileSize: 10 * 1024 * 1024,
  },

  fileFilter: (req, file, cb) => {
    const extension = path
      .extname(file.originalname || '')
      .toLowerCase();

    const mimeType = String(
      file.mimetype || '',
    ).toLowerCase();

    const allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
    ];

    const allowedMimeTypes = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/webp',
      'image/gif',
      'application/octet-stream',
    ];

    if (
      allowedExtensions.includes(extension) &&
      allowedMimeTypes.includes(mimeType)
    ) {
      return cb(null, true);
    }

    if (
      allowedExtensions.includes(extension)
    ) {
      return cb(null, true);
    }

    return cb(
      new Error(
        'Only JPG, JPEG, PNG, WEBP and GIF image files are allowed.',
      ),
    );
  },
}).single('image');
// ADMIN - DELETE GALLERY

app.delete(
  '/api/admin/gallery/:id',
  admin,
  async (req, res) => {
    try {
      const id =
        req.params.id;

      const result =
        await db.query(
          `
          DELETE FROM gallery
          WHERE id=$1
          RETURNING *
          `,
          [id],
        );

      if (
        result.rows.length === 0
      ) {
        return res.status(404).json({
          error:
            'Gallery post not found.',
        });
      }

      const imageUrl = String(result.rows[0].image_url || '');
      if (imageUrl.startsWith('/uploads/gallery/')) {
        const filePath = path.join(__dirname, imageUrl.replace(/^\//, ''));
        fs.unlink(filePath, () => {});
      }

      res.json({
        message:
          'Gallery post deleted successfully.',
      });
    } catch (error) {
      console.error(
        'Delete gallery error:',
        error,
      );

      res.status(500).json({
        error:
          'Unable to delete gallery post',

        details:
          error.message,
      });
    }
  },
);

// ==========================================================
// ADMISSIONS
// ==========================================================

// GET ALL ADMISSIONS

app.get(
  '/api/admissions',
  admin,
  async (_, res) => {
    try {
      const result =
        await db.query(`
          SELECT
            id,
            student_name,
            father_name,
            mother_name,
            dob,
            class_name,
            mobile,
            email,
            address,
            status,
            created_at
          FROM admissions
          ORDER BY created_at DESC
        `);

      res.json(
        result.rows,
      );
    } catch (error) {
      console.error(
        'Get admissions error:',
        error,
      );

      res.status(500).json({
        message:
          'Database se admissions fetch nahi ho rahe.',
        error:
          error.message,
      });
    }
  },
);

// GET SINGLE ADMISSION

app.get(
  '/api/admissions/:id',
  admin,
  async (req, res) => {
    try {
      const result =
        await db.query(
          `
          SELECT *
          FROM admissions
          WHERE id=$1
          `,
          [req.params.id],
        );

      if (
        result.rows.length === 0
      ) {
        return res.status(404).json({
          message:
            'Admission nahi mila.',
        });
      }

      res.json(
        result.rows[0],
      );
    } catch (error) {
      console.error(
        'Get admission error:',
        error,
      );

      res.status(500).json({
        message:
          'Database error.',
        error:
          error.message,
      });
    }
  },
);

// CREATE ADMISSION

app.post(
  '/api/admissions',
  async (req, res) => {
    try {
      const data =
        req.body || {};

      const studentName =
        String(
          data.student_name || '',
        ).trim();

      const fatherName =
        String(
          data.father_name || '',
        ).trim();

      const motherName =
        String(
          data.mother_name || '',
        ).trim();

      const className =
        String(
          data.class_name || '',
        ).trim();

      const mobile =
        String(
          data.mobile || '',
        ).trim();

      const email =
        String(
          data.email || '',
        ).trim();

      const address =
        String(
          data.address || '',
        ).trim();

      const dob =
        data.dob
          ? String(
              data.dob,
            ).trim()
          : null;

      if (
        !studentName ||
        !fatherName ||
        !className ||
        !mobile
      ) {
        return res.status(400).json({
          message:
            'Student name, father name, class aur mobile required hain.',
        });
      }

      if (
        !/^[0-9]{10}$/.test(
          mobile,
        )
      ) {
        return res.status(400).json({
          message:
            'Mobile number exactly 10 digits ka hona chahiye.',
        });
      }

      if (
        dob &&
        !/^\d{4}-\d{2}-\d{2}$/.test(
          dob,
        )
      ) {
        return res.status(400).json({
          message:
            'Date of birth must be YYYY-MM-DD.',
        });
      }

      const result =
        await db.query(
          `
          INSERT INTO admissions
            (
              student_name,
              father_name,
              mother_name,
              dob,
              class_name,
              mobile,
              email,
              address,
              status
            )
          VALUES
            (
              $1,$2,$3,$4,$5,
              $6,$7,$8,'Pending'
            )
          RETURNING *
          `,
          [
            studentName,
            fatherName,
            motherName ||
              null,
            dob,
            className,
            mobile,
            email || null,
            address || null,
          ],
        );

      res.status(201).json({
        message:
          'Admission successfully create ho gaya.',
        admission:
          result.rows[0],
      });
    } catch (error) {
      console.error(
        'Create admission error:',
        error,
      );

      res.status(500).json({
        message:
          'Admission save nahi ho raha.',
        error:
          error.message,
      });
    }
  },
);

// UPDATE ADMISSION STATUS

app.patch(
  '/api/admissions/:id/status',
  admin,
  async (req, res) => {
    try {
      const status =
        String(
          req.body?.status || '',
        );

      const allowedStatuses = [
        'Pending',
        'Approved',
        'Rejected',
      ];

      if (
        !allowedStatuses.includes(
          status,
        )
      ) {
        return res.status(400).json({
          message:
            'Invalid admission status.',
        });
      }

      const result =
        await db.query(
          `
          UPDATE admissions
          SET status=$1
          WHERE id=$2
          RETURNING *
          `,
          [
            status,
            req.params.id,
          ],
        );

      if (
        result.rows.length === 0
      ) {
        return res.status(404).json({
          message:
            'Admission nahi mila.',
        });
      }

      res.json({
        message:
          'Admission status update ho gaya.',
        admission:
          result.rows[0],
      });
    } catch (error) {
      console.error(
        'Update status error:',
        error,
      );

      res.status(500).json({
        message:
          'Status update nahi ho raha.',
        error:
          error.message,
      });
    }
  },
);

// DELETE ADMISSION

app.delete(
  '/api/admissions/:id',
  admin,
  async (req, res) => {
    try {
      const result =
        await db.query(
          `
          DELETE FROM admissions
          WHERE id=$1
          RETURNING id
          `,
          [req.params.id],
        );

      if (
        result.rows.length === 0
      ) {
        return res.status(404).json({
          message:
            'Admission nahi mila.',
        });
      }

      res.json({
        message:
          'Admission delete ho gaya.',
      });
    } catch (error) {
      console.error(
        'Delete admission error:',
        error,
      );

      res.status(500).json({
        message:
          'Admission delete nahi ho raha.',
        error:
          error.message,
      });
    }
  },
);
// ADMIN - UPLOAD FACULTY PHOTO

app.post(
  '/api/admin/faculty/upload',
  admin,
  (req, res) => {
    uploadFacultyImage(req, res, (error) => {
      if (error) {
        console.error(
          'Faculty image upload error:',
          error,
        );

        return res.status(400).json({
          error:
            error.message ||
            'Unable to upload faculty image.',
        });
      }

      if (!req.file) {
        return res.status(400).json({
          error: 'Please select an image.',
        });
      }

      const imageUrl =
        `/uploads/faculty/${req.file.filename}`;

      res.json({
        ok: true,
        message:
          'Faculty photo uploaded successfully.',
        image_url: imageUrl,
      });
    });
  },
);
// ==========================================================
// FACULTY API
// ==========================================================

// PUBLIC - GET ALL FACULTY
app.get(
  '/api/faculty',
  async (_, res) => {
    try {
      const result = await db.query(`
        SELECT
          id,
          name,
          designation,
          subject,
          description,
          image_url,
          is_principal,
          created_at
        FROM faculty
        ORDER BY is_principal DESC, created_at ASC
      `);

      res.json(result.rows);
    } catch (error) {
      console.error(
        'Get faculty error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to load faculty',
        details: error.message,
      });
    }
  },
);

// ADMIN - ADD FACULTY
app.post(
  '/api/admin/faculty',
  admin,
  async (req, res) => {
    try {
      const data = req.body || {};

      const name = String(
        data.name || '',
      ).trim();

      const designation = String(
        data.designation || '',
      ).trim();

      const subject = String(
        data.subject || '',
      ).trim();

      const description = String(
        data.description || '',
      ).trim();

      const imageUrl = String(
        data.image_url || '',
      ).trim();

      const isPrincipal =
  data.is_principal === true ||
  data.is_principal === 'true';

      if (!name || !designation) {
        return res.status(400).json({
          error:
            'Name and designation are required.',
        });
      }

      if (isPrincipal) {
        await db.query(`
          UPDATE faculty
          SET is_principal = FALSE
          WHERE is_principal = TRUE
        `);
      }

      const result = await db.query(
        `
        INSERT INTO faculty
          (
            name,
            designation,
            subject,
            description,
            image_url,
            is_principal
          )
        VALUES
          ($1,$2,$3,$4,$5,$6)
        RETURNING *
        `,
        [
          name,
          designation,
          subject,
          description,
          imageUrl,
          isPrincipal,
        ],
      );

      res.status(201).json({
        ok: true,
        message: 'Faculty added successfully.',
        faculty: result.rows[0],
      });
    } catch (error) {
      console.error(
        'Add faculty error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to add faculty',
        details: error.message,
      });
    }
  },
);

// ADMIN - UPDATE FACULTY
app.put(
  '/api/admin/faculty/:id',
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          error: 'Invalid faculty ID.',
        });
      }

      const data = req.body || {};

      const name = String(
        data.name || '',
      ).trim();

      const designation = String(
        data.designation || '',
      ).trim();

      const subject = String(
        data.subject || '',
      ).trim();

      const description = String(
        data.description || '',
      ).trim();

      const imageUrl = String(
        data.image_url || '',
      ).trim();

      const isPrincipal =
        data.is_principal === true;

      if (!name || !designation) {
        return res.status(400).json({
          error:
            'Name and designation are required.',
        });
      }

      if (isPrincipal) {
        await db.query(
          `
          UPDATE faculty
          SET is_principal = FALSE
          WHERE id <> $1
          `,
          [id],
        );
      }

      const result = await db.query(
        `
        UPDATE faculty
        SET
          name = $1,
          designation = $2,
          subject = $3,
          description = $4,
          image_url = $5,
          is_principal = $6
        WHERE id = $7
        RETURNING *
        `,
        [
          name,
          designation,
          subject,
          description,
          imageUrl,
          isPrincipal,
          id,
        ],
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          error: 'Faculty member not found.',
        });
      }

      res.json({
        ok: true,
        message: 'Faculty updated successfully.',
        faculty: result.rows[0],
      });
    } catch (error) {
      console.error(
        'Update faculty error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to update faculty',
        details: error.message,
      });
    }
  },
);

// ADMIN - DELETE FACULTY
app.delete(
  '/api/admin/faculty/:id',
  admin,
  async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!Number.isInteger(id)) {
        return res.status(400).json({
          error: 'Invalid faculty ID.',
        });
      }

      const result = await db.query(
        `
        DELETE FROM faculty
        WHERE id = $1
        RETURNING id
        `,
        [id],
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          error: 'Faculty member not found.',
        });
      }

      res.json({
        ok: true,
        message: 'Faculty deleted successfully.',
      });
    } catch (error) {
      console.error(
        'Delete faculty error:',
        error,
      );

      res.status(500).json({
        error: 'Unable to delete faculty',
        details: error.message,
      });
    }
  },
);
// ==========================================================
// DATABASE INITIALIZATION
// ==========================================================

async function initializeDatabase() {
  const schemaPath =
    path.join(
      __dirname,
      '..',
      'schema.sql',
    );

  const schema =
    fs.readFileSync(
      schemaPath,
      'utf8',
    );

  await db.query(
    schema,
  );
  // --------------------------------------------------------
  // CONTACT MESSAGES - READ/UNREAD
  // --------------------------------------------------------

  await db.query(`
    ALTER TABLE contact_messages
    ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT FALSE
  `);

  console.log(
    '✅ Contact messages read/unread checked',
  );
  // --------------------------------------------------------
// INQUIRIES - EMAIL
// --------------------------------------------------------

await db.query(`
  ALTER TABLE inquiries
  ADD COLUMN IF NOT EXISTS email TEXT
`);

console.log(
  '✅ Inquiries email column checked',
);
  // --------------------------------------------------------
  // GALLERY TABLE
  // --------------------------------------------------------

  await db.query(`
    CREATE TABLE IF NOT EXISTS gallery (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT DEFAULT '',
      image_url TEXT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL
        DEFAULT NOW()
    )
  `);

  console.log(
    '✅ Gallery table checked/created',
  );
// --------------------------------------------------------
// ABOUT / FACULTY TABLE
// --------------------------------------------------------

await db.query(`
  CREATE TABLE IF NOT EXISTS faculty (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    designation TEXT NOT NULL,
    subject TEXT DEFAULT '',
    description TEXT DEFAULT '',
    image_url TEXT DEFAULT '',
    is_principal BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  )
`);

console.log(
  '✅ Faculty table checked/created',
);
  // --------------------------------------------------------
  // ADMIN USER
  // --------------------------------------------------------

  const username =
    String(
      process.env.ADMIN_USERNAME ||
        'admin',
    ).trim();

  const password =
    String(
      process.env.ADMIN_PASSWORD ||
        '',
    );

  if (password) {
    const hash =
      await bcrypt.hash(
        password,
        12,
      );

    await db.query(
      `
      INSERT INTO admin_users
        (
          username,
          password_hash
        )
      VALUES
        ($1,$2)
      ON CONFLICT(username)
      DO UPDATE SET
        password_hash =
          EXCLUDED.password_hash
      `,
      [
        username,
        hash,
      ],
    );

    console.log(
      '✅ Admin user checked/updated',
    );
  }

  // --------------------------------------------------------
  // DEFAULT WEBSITE CONTENT
  // --------------------------------------------------------

  await db.query(`
    INSERT INTO site_content
      (
        id,
        hero_title,
        hero_text,
        about_title,
        about_text,
        academics_title,
        academics_text,
        student_life_title,
        student_life_text,
        rules_title,
        rules_text
      )
    VALUES
      (
        1,
        'Learn. Grow. Shine.',
        'Welcome to Maa Saraswati Public School, Lucknow.',
        'Education with Knowledge and Values',
        'A caring and disciplined learning environment.',
        'Strong Academic Foundation',
        'A structured and supportive approach to learning.',
        'Student Life',
        'Activities, discipline, confidence and positive values.',
        'Rules & Guidelines',
        'Important school rules and parent guidelines.'
      )
    ON CONFLICT(id)
    DO NOTHING
  `);

  console.log(
    '✅ Website content checked',
  );
}

// ==========================================================
// START SERVER
// ==========================================================

async function startServer() {
  try {
    const info =
      await db.testConnection();

    console.log(
      '✅ Database connection successful',
    );

    console.log(
      'Database:',
      info.current_database,
    );

    console.log(
      'User:',
      info.current_user,
    );

    await initializeDatabase();

    console.log(
      '✅ Database tables checked/created',
    );

    app.listen(
      port,
      () => {
        console.log(
          `School CMS API: http://localhost:${port}`,
        );

        console.log(
          `Health check: http://localhost:${port}/api/health`,
        );
      },
    );
  } catch (error) {
    console.error(
      '❌ Server startup failed',
    );

    console.error(
      error,
    );

    process.exit(1);
  }
}

startServer();