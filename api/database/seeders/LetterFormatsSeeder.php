<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LetterFormatsSeeder extends Seeder
{
    public function run()
    {
        $now = Carbon::now();

        $data = [
            [
                'name' => 'Surat Izin Cuti Tahunan',
                'content' => '
                    Kepada Yth,
                    HR Department

                    Dengan hormat,
                    Saya mengajukan permohonan izin cuti tahunan sesuai dengan ketentuan perusahaan.
                    Mohon persetujuannya agar proses cuti dapat dilakukan sesuai jadwal yang telah direncanakan.

                    Hormat saya,
                    [NAMA KARYAWAN]
                ',
                'created_at' => $now,
                'updated_at' => $now,
            ],
            [
                'name' => 'Surat Cuti di Luar Tanggungan Perusahaan',
                'content' => '
                    Kepada Yth,
                    HR Department

                    Dengan hormat,
                    Saya mengajukan permohonan cuti di luar tanggungan perusahaan karena alasan pribadi.
                    Saya memahami bahwa selama periode ini saya tidak menerima hak dan fasilitas perusahaan.

                    Hormat saya,
                    [NAMA KARYAWAN]
                ',
                'created_at' => $now,
                'updated_at' => $now,
            ],
            [
                'name' => 'Surat Izin Tugas Perusahaan',
                'content' => '
                    Kepada Yth,
                    Pimpinan Perusahaan

                    Dengan hormat,
                    Surat ini diterbitkan untuk memberikan tugas kepada karyawan terkait untuk melaksanakan tugas perusahaan sesuai penugasan yang telah ditetapkan.

                    Hormat kami,
                    [MANAGEMENT]
                ',
                'created_at' => $now,
                'updated_at' => $now,
            ],
        ];

        DB::table('letter_formats')->insert($data);
    }
}
