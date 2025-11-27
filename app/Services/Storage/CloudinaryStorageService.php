<?php

namespace App\Services\Storage;

use App\Contracts\StorageServiceInterface;
use Cloudinary\Cloudinary;
use Cloudinary\Transformation\Resize;
use Illuminate\Http\UploadedFile;

class CloudinaryStorageService implements StorageServiceInterface
{
    protected Cloudinary $cloudinary;

    public function __construct()
    {
        $this->cloudinary = new Cloudinary([
            'cloud' => [
                'cloud_name' => config('services.cloudinary.cloud_name'),
                'api_key' => config('services.cloudinary.api_key'),
                'api_secret' => config('services.cloudinary.api_secret'),
            ],
            'url' => [
                'secure' => true
            ]
        ]);
    }

    /**
     * Upload a file to Cloudinary
     *
     * @param UploadedFile $file
     * @param string $folder
     * @param array $options
     * @return array
     */
    public function upload(UploadedFile $file, string $folder = '', array $options = []): array
    {
        $resourceType = $this->getResourceType($file);

        $uploadOptions = array_merge([
            'folder' => $folder,
            'resource_type' => $resourceType,
        ], $options);

        $result = $this->cloudinary->uploadApi()->upload(
            $file->getRealPath(),
            $uploadOptions
        );

        return [
            'url' => $result['secure_url'],
            'public_id' => $result['public_id'],
            'format' => $result['format'],
            'size' => $result['bytes'],
            'width' => $result['width'] ?? null,
            'height' => $result['height'] ?? null,
            'resource_type' => $resourceType,
        ];
    }

    /**
     * Delete a file from Cloudinary
     *
     * @param string $publicId
     * @return bool
     */
    public function delete(string $publicId): bool
    {
        try {
            $this->cloudinary->uploadApi()->destroy($publicId);
            return true;
        } catch (\Exception $e) {
            \Log::error('Cloudinary delete error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Get file URL from Cloudinary
     *
     * @param string $publicId
     * @param array $transformations
     * @return string
     */
    public function getUrl(string $publicId, array $transformations = []): string
    {
        if (empty($transformations)) {
            return $this->cloudinary->image($publicId)->toUrl();
        }

        return $this->cloudinary->image($publicId)
            ->resize(Resize::fill($transformations['width'] ?? 300, $transformations['height'] ?? 300))
            ->toUrl();
    }

    /**
     * Generate thumbnail for video
     *
     * @param string $publicId
     * @param array $options
     * @return string
     */
    public function generateVideoThumbnail(string $publicId, array $options = []): string
    {
        $width = $options['width'] ?? 300;
        $height = $options['height'] ?? 300;

        return $this->cloudinary->video($publicId)
            ->resize(Resize::fill($width, $height))
            ->format('jpg')
            ->toUrl();
    }

    /**
     * Determine resource type based on file mime type
     *
     * @param UploadedFile $file
     * @return string
     */
    protected function getResourceType(UploadedFile $file): string
    {
        $mimeType = $file->getMimeType();

        if (str_starts_with($mimeType, 'video/')) {
            return 'video';
        }

        if (str_starts_with($mimeType, 'image/')) {
            return 'image';
        }

        return 'auto';
    }
}
