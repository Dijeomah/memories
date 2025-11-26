<?php

namespace App\Services;

use SimpleSoftwareIO\QrCode\Facades\QrCode;
use Illuminate\Support\Str;

class QRCodeService
{
    /**
     * Generate a unique QR code data string
     *
     * @return string
     */
    public function generateUniqueCode(): string
    {
        return Str::uuid()->toString();
    }

    /**
     * Generate QR code image
     *
     * @param string $data
     * @param int $size
     * @return string Base64 encoded QR code
     */
    public function generate(string $data, int $size = 300): string
    {
        return base64_encode(
            QrCode::format('png')
                ->size($size)
                ->generate($data)
        );
    }

    /**
     * Generate QR code SVG
     *
     * @param string $data
     * @param int $size
     * @return string
     */
    public function generateSvg(string $data, int $size = 300): string
    {
        return QrCode::format('svg')
            ->size($size)
            ->generate($data);
    }

    /**
     * Get QR code scan URL
     *
     * @param string $qrCodeData
     * @return string
     */
    public function getScanUrl(string $qrCodeData): string
    {
        return url("/scan/{$qrCodeData}");
    }
}
