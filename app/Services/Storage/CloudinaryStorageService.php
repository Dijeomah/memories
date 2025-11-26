<?php

namespace App\Services\Storage;

use App\Contracts\StorageServiceInterface;
use CloudinaryLabs\CloudinaryLaravel\Facades\Cloudinary;
use Illuminate\Http\UploadedFile;

class CloudinaryStorageService implements StorageServiceInterface
{
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
            'folder' => $folder ?: config('cloudinary.upload_preset'),
            'resource_type' => $resourceType,
        ], $options);

        $result = Cloudinary::upload($file->getRealPath(), $uploadOptions);

        return [
            'url' => $result->getSecurePath(),
            'public_id' => $result->getPublicId(),
            'format' => $result->getExtension(),
            'size' => $result->getSize(),
            'width' => $result->getWidth() ?? null,
            'height' => $result->getHeight() ?? null,
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
            Cloudinary::destroy($publicId);
            return true;
        } catch (\Exception $e) {
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
            return Cloudinary::getUrl($publicId);
        }

        return Cloudinary::getUrl($publicId, $transformations);
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
        $defaultOptions = [
            'resource_type' => 'video',
            'format' => 'jpg',
            'transformation' => [
                'width' => 300,
                'height' => 300,
                'crop' => 'fill',
            ]
        ];

        $options = array_merge($defaultOptions, $options);

        return Cloudinary::getUrl($publicId, $options);
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
