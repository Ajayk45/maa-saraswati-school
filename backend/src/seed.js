const bcrypt=require('bcryptjs');const fs=require('fs');require('dotenv').config();const db=require('./db');
(async()=>{
  const schema=fs.readFileSync(require('path').join(__dirname,'..','schema.sql'),'utf8');
  await db.query(schema);
  const hash=await bcrypt.hash(process.env.ADMIN_PASSWORD||'change-me',12);
  await db.query(`INSERT INTO admin_users(username,password_hash) VALUES($1,$2)
    ON CONFLICT(username) DO UPDATE SET password_hash=EXCLUDED.password_hash`,
    [process.env.ADMIN_USERNAME||'admin',hash]);
  await db.query(`INSERT INTO site_content
    (id,hero_title,hero_text,about_title,about_text,academics_title,academics_text,student_life_title,student_life_text,rules_title,rules_text)
    VALUES(1,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
    ON CONFLICT(id) DO NOTHING`,
    [
      'Learn. Grow. Shine.',
      'Welcome to Maa Saraswati Public School, Lucknow — a caring and disciplined learning environment for students up to Class XII.',
      'Education with Knowledge and Values',
      'Maa Saraswati Public School, Near By Kisan Path, Juggour, Chinhat, Lucknow, focuses on meaningful learning, discipline, confidence and overall student development.',
      'Strong Academic Foundation',
      'Our academic environment supports students through a clear, structured and supportive approach to learning from the early classes through Class XII.',
      'Student Life',
      'School life is designed to encourage discipline, participation, confidence, good habits and positive relationships between students, teachers and parents.',
      'Rules & Guidelines',
      'Important school rules, admission information, uniform guidance, transport information and other parent guidelines can be updated by the school administrator without changing website code.'
    ]);
  console.log('Admin seeded:',process.env.ADMIN_USERNAME||'admin');
  await db.pool.end();
})().catch(e=>{console.error(e);process.exit(1)});
